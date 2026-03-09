import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

// Forbidden keywords filter
const FORBIDDEN_PATTERNS = [
  /외모|얼굴|몸매|체형|키가|피부|살이/g,
  /섹시|야한|성적|19금/g,
  /인종|민족|국적차별/g,
];

function filterResponse(text: string): string {
  let filtered = text;
  for (const pattern of FORBIDDEN_PATTERNS) {
    filtered = filtered.replace(pattern, '***');
  }
  return filtered;
}

// Fallback response when AI fails
function getFallbackAnalysis(myProfile: any, otherProfile: any) {
  const myInterests = myProfile.interests || [];
  const otherInterests = otherProfile.interests || [];
  const common = myInterests.filter((i: string) => otherInterests.includes(i));
  
  const rating = common.length >= 3 ? 'good' : common.length >= 1 ? 'moderate' : 'low';
  
  const strengths = [];
  if (common.length > 0) strengths.push(`공통 관심사: ${common.slice(0, 3).join(', ')}`);
  if (myProfile.city && otherProfile.city && myProfile.city === otherProfile.city) strengths.push('같은 도시에 살고 있어요');
  if (strengths.length === 0) strengths.push('새로운 관심사를 공유할 수 있어요');
  strengths.push('대화를 통해 더 알아가보세요');
  
  return {
    summary: common.length > 0 
      ? `${common.join(', ')} 등 공통 관심사가 있어요! 대화를 시작해보세요.`
      : '서로 다른 관심사를 가지고 있어 새로운 경험을 공유할 수 있을 거예요.',
    strengths: strengths.slice(0, 3),
    conversation_starters: [
      common.length > 0 ? `${common[0]}에 대해 이야기해보세요` : '서로의 취미에 대해 물어보세요',
      '최근에 재미있었던 경험을 공유해보세요'
    ],
    compatibility_rating: rating,
    is_fallback: true,
  };
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const { myProfile, otherProfile, myPrompts, otherPrompts } = await req.json();
    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) throw new Error("LOVABLE_API_KEY is not configured");

    const systemPrompt = `당신은 데이팅 앱의 매칭 분석 전문가입니다. 두 사람의 프로필을 분석하여 호환성을 평가합니다.

중요 규칙:
- 반드시 한국어로 답변하세요.
- 따뜻하고 긍정적인 톤을 유지하되, 솔직하게 분석하세요.
- 절대로 외모, 체형, 피부, 인종에 대한 언급을 하지 마세요.
- 성적이거나 부적절한 내용을 포함하지 마세요.
- 프로필 데이터에 없는 정보를 추측하거나 지어내지 마세요.
- 관심사, 성격, 가치관 중심으로만 분석하세요.
- 답변은 간결하게, summary는 2-3문장 이내로 작성하세요.`;

    const userPrompt = `다음 두 프로필을 분석하고 호환성을 평가해주세요.

**나의 프로필:**
- 이름: ${myProfile.display_name}
- 나이: ${myProfile.age}세
- 위치: ${myProfile.city || '미설정'}
- 관심사: ${(myProfile.interests || []).join(', ') || '없음'}
- 자기소개: ${myProfile.bio || '없음'}
${myPrompts?.length ? `- 프롬프트 답변:\n${myPrompts.map((p: any) => `  Q: ${p.prompt_question}\n  A: ${p.prompt_answer}`).join('\n')}` : ''}

**상대방 프로필:**
- 이름: ${otherProfile.display_name}
- 나이: ${otherProfile.age}세
- 위치: ${otherProfile.city || '미설정'}
- 관심사: ${(otherProfile.interests || []).join(', ') || '없음'}
- 자기소개: ${otherProfile.bio || '없음'}
${otherPrompts?.length ? `- 프롬프트 답변:\n${otherPrompts.map((p: any) => `  Q: ${p.prompt_question}\n  A: ${p.prompt_answer}`).join('\n')}` : ''}`;

    const response = await fetch("https://ai.gateway.lovable.dev/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${LOVABLE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "google/gemini-2.5-flash-lite",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userPrompt },
        ],
        tools: [
          {
            type: "function",
            function: {
              name: "analyze_compatibility",
              description: "Return compatibility analysis between two profiles",
              parameters: {
                type: "object",
                properties: {
                  summary: {
                    type: "string",
                    description: "2-3 sentence summary of compatibility in Korean, warm tone. No mention of appearance."
                  },
                  strengths: {
                    type: "array",
                    items: { type: "string" },
                    description: "3 key compatibility strengths as short phrases in Korean. Focus on interests and values only."
                  },
                  conversation_starters: {
                    type: "array",
                    items: { type: "string" },
                    description: "2 suggested conversation starter topics in Korean"
                  },
                  compatibility_rating: {
                    type: "string",
                    enum: ["excellent", "good", "moderate", "low"],
                    description: "Overall compatibility rating"
                  }
                },
                required: ["summary", "strengths", "conversation_starters", "compatibility_rating"],
                additionalProperties: false
              }
            }
          }
        ],
        tool_choice: { type: "function", function: { name: "analyze_compatibility" } },
      }),
    });

    if (!response.ok) {
      if (response.status === 429) {
        return new Response(JSON.stringify({ error: "요청이 너무 많습니다. 잠시 후 다시 시도해주세요." }), {
          status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      if (response.status === 402) {
        return new Response(JSON.stringify({ error: "AI 크레딧이 부족합니다." }), {
          status: 402, headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      // Fallback on AI error
      console.error("AI gateway error:", response.status);
      const fallback = getFallbackAnalysis(myProfile, otherProfile);
      return new Response(JSON.stringify(fallback), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const data = await response.json();
    const toolCall = data.choices?.[0]?.message?.tool_calls?.[0];
    
    if (!toolCall?.function?.arguments) {
      // Fallback if no tool call
      const fallback = getFallbackAnalysis(myProfile, otherProfile);
      return new Response(JSON.stringify(fallback), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const analysis = JSON.parse(toolCall.function.arguments);
    
    // Filter response for safety
    analysis.summary = filterResponse(analysis.summary);
    analysis.strengths = analysis.strengths.map((s: string) => filterResponse(s));
    analysis.conversation_starters = analysis.conversation_starters.map((s: string) => filterResponse(s));

    return new Response(JSON.stringify(analysis), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("ai-compatibility error:", e);
    // Always return fallback instead of error for better UX
    try {
      const body = await req.clone().json();
      const fallback = getFallbackAnalysis(body.myProfile || {}, body.otherProfile || {});
      return new Response(JSON.stringify(fallback), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch {
      return new Response(JSON.stringify({ error: "AI 분석에 실패했습니다" }), {
        status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
  }
});
