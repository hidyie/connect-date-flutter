import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version",
};

// Forbidden keywords filter
const FORBIDDEN_PATTERNS = [
  /외모|얼굴|몸매|체형|키가|피부|살이/g,
  /섹시|야한|성적|19금/g,
  /만나서 뭐 할|집에|술 먹고/g,
];

function filterSuggestions(suggestions: string[]): string[] {
  return suggestions.map(s => {
    let filtered = s;
    for (const pattern of FORBIDDEN_PATTERNS) {
      if (pattern.test(filtered)) {
        return null; // Remove entirely if inappropriate
      }
    }
    return filtered;
  }).filter(Boolean) as string[];
}

// Fallback suggestions when AI fails
function getFallbackSuggestions(myProfile: any, partnerProfile: any): string[] {
  const partnerName = partnerProfile?.display_name || '상대방';
  const partnerInterests = partnerProfile?.interests || [];
  const myInterests = myProfile?.interests || [];
  const common = myInterests.filter((i: string) => partnerInterests.includes(i));

  const suggestions = [
    `안녕하세요 ${partnerName}님! 프로필 보고 인상 깊어서 먼저 연락드려요 😊`,
    partnerProfile?.bio ? `자기소개가 인상적이에요! 더 이야기 나눠보고 싶어요` : `${partnerName}님은 요즘 어떤 것에 관심이 있으세요?`,
  ];

  if (common.length > 0) {
    suggestions.push(`저도 ${common[0]} 좋아하는데, ${partnerName}님은 어떤 걸 주로 하세요?`);
    suggestions.push(`${common[0]} 좋아하시는 분을 만나서 반갑네요! 🎉`);
  } else if (partnerInterests.length > 0) {
    suggestions.push(`${partnerInterests[0]}에 관심 있으시군요! 저한테도 추천해주실 수 있어요?`);
    suggestions.push(`${partnerName}님의 취미가 궁금해요, 더 알려주세요!`);
  } else {
    suggestions.push(`주말에는 보통 뭐 하면서 시간 보내세요?`);
    suggestions.push(`요즘 빠져 있는 것이 있으세요? 😄`);
  }

  return suggestions.slice(0, 4);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });

  try {
    const { myProfile, partnerProfile, myPrompts, partnerPrompts } = await req.json();
    const LOVABLE_API_KEY = Deno.env.get("LOVABLE_API_KEY");
    if (!LOVABLE_API_KEY) throw new Error("LOVABLE_API_KEY is not configured");

    const systemPrompt = `당신은 데이팅 앱의 대화 전문가입니다. 두 사람의 프로필을 분석하여 자연스럽고 매력적인 첫 메시지를 제안합니다.

중요 규칙:
- 반드시 한국어로 답변하세요.
- 메시지는 자연스럽고 친근하며, 상대방이 답하고 싶어지는 질문이나 화제를 포함해야 합니다.
- 너무 형식적이거나 딱딱하지 않게, 실제 채팅처럼 자연스러운 톤으로 작성하세요.
- 절대로 외모, 체형, 신체적 특징에 대한 언급을 하지 마세요.
- 성적이거나 부적절한 내용, 만남 장소 제안을 하지 마세요.
- 프로필에 없는 정보를 추측하지 마세요.
- 관심사와 취미 중심의 자연스러운 대화 시작을 제안하세요.
- 각 메시지는 1-2문장으로 간결하게 작성하세요.`;

    const userPrompt = `다음 두 프로필을 기반으로 자연스러운 첫 메시지 4개를 제안해주세요.

**나:**
- 이름: ${myProfile.display_name}
- 관심사: ${(myProfile.interests || []).join(', ') || '없음'}
- 자기소개: ${myProfile.bio || '없음'}
${myPrompts?.length ? `- 프롬프트:\n${myPrompts.map((p: any) => `  Q: ${p.prompt_question} A: ${p.prompt_answer}`).join('\n')}` : ''}

**상대방:**
- 이름: ${partnerProfile.display_name}
- 관심사: ${(partnerProfile.interests || []).join(', ') || '없음'}
- 자기소개: ${partnerProfile.bio || '없음'}
${partnerPrompts?.length ? `- 프롬프트:\n${partnerPrompts.map((p: any) => `  Q: ${p.prompt_question} A: ${p.prompt_answer}`).join('\n')}` : ''}`;

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
              name: "suggest_icebreakers",
              description: "Return 4 natural first message suggestions in Korean. No appearance comments.",
              parameters: {
                type: "object",
                properties: {
                  suggestions: {
                    type: "array",
                    items: { type: "string" },
                    description: "4 natural first message suggestions, each 1-2 sentences, casual chat tone. Focus on interests only."
                  }
                },
                required: ["suggestions"],
                additionalProperties: false
              }
            }
          }
        ],
        tool_choice: { type: "function", function: { name: "suggest_icebreakers" } },
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
      console.error("AI gateway error:", response.status);
      // Fallback
      return new Response(JSON.stringify({ suggestions: getFallbackSuggestions(myProfile, partnerProfile) }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const data = await response.json();
    const toolCall = data.choices?.[0]?.message?.tool_calls?.[0];
    if (!toolCall?.function?.arguments) {
      return new Response(JSON.stringify({ suggestions: getFallbackSuggestions(myProfile, partnerProfile) }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const result = JSON.parse(toolCall.function.arguments);
    
    // Filter and validate suggestions
    const filtered = filterSuggestions(result.suggestions || []);
    
    // If filtering removed too many, supplement with fallback
    if (filtered.length < 2) {
      const fallback = getFallbackSuggestions(myProfile, partnerProfile);
      result.suggestions = [...filtered, ...fallback].slice(0, 4);
    } else {
      result.suggestions = filtered.slice(0, 4);
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("ai-icebreaker error:", e);
    try {
      const body = await req.clone().json();
      return new Response(JSON.stringify({ suggestions: getFallbackSuggestions(body.myProfile || {}, body.partnerProfile || {}) }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch {
      return new Response(JSON.stringify({ error: "AI 추천에 실패했습니다" }), {
        status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
  }
});
