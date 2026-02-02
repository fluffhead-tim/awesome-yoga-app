const express = require('express');
const OpenAI = require('openai');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 12000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Single-word alternatives to "awesome" (never includes "awesome" or "amazing")
const awesomeAlternatives = [
  'wonderful', 'beautiful', 'excellent', 'fantastic', 'magnificent',
  'brilliant', 'outstanding', 'remarkable', 'exceptional', 'superb',
  'splendid', 'marvelous', 'terrific', 'fabulous', 'glorious',
  'stunning', 'impressive', 'phenomenal', 'extraordinary', 'sublime',
  'radiant', 'graceful', 'elegant', 'powerful', 'steady',
  'strong', 'balanced', 'centered', 'grounded', 'focused',
  'mindful', 'present', 'aligned', 'engaged', 'intentional'
];

// Random word endpoint
app.get('/api/random-word', (req, res) => {
  const randomIndex = Math.floor(Math.random() * awesomeAlternatives.length);
  res.json({ word: awesomeAlternatives[randomIndex] });
});

// AI-powered contextual cue endpoint
app.post('/api/generate-cue', async (req, res) => {
  const { phrase } = req.body;
  
  if (!phrase || phrase.trim() === '') {
    return res.status(400).json({ error: 'Please provide a phrase' });
  }

  // Check if OpenAI API key is available
  const apiKey = process.env.OPENAI_API_KEY;
  
  if (!apiKey) {
    // Fallback response if no API key
    return res.json({ 
      cue: getFallbackCue(phrase),
      note: 'Using fallback mode. Set OPENAI_API_KEY for AI-powered cues.'
    });
  }

  try {
    const openai = new OpenAI({ apiKey });
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are an expert yoga instructor helping other yoga teachers find better alternatives to saying "awesome" in their classes.

IMPORTANT RULES:
- NEVER use the words "awesome" or "amazing" in your responses
- Provide specific, instructive feedback that helps students understand their alignment and form
- If a yoga pose is mentioned (in English or Sanskrit), provide a cue specific to that pose
- If no specific pose is mentioned, select a random common yoga pose and create a cue for it
- Focus on alignment, breath, engagement, or sensation cues
- Keep responses concise and suitable for use during a yoga class
- The cue should be encouraging but instructive, not cheerleading

Examples of good cues:
- "I love how your front knee is tracking over your ankle in Warrior II"
- "Beautiful extension through your spine in Downward Dog"
- "Notice how grounded your standing leg feels in Tree Pose"
- "Your hip alignment in Pigeon is looking wonderful today"`
        },
        {
          role: 'user',
          content: `A yoga teacher wants to say "${phrase}" to their students. Provide an alternative phrase that:
1. Does NOT use "awesome" or "amazing"
2. Includes a specific, instructive cue about the pose
3. Is encouraging but educational

Respond with just the alternative cue, nothing else.`
        }
      ],
      max_tokens: 150,
      temperature: 0.8
    });

    const cue = completion.choices[0].message.content.trim();
    
    // Double-check the response doesn't contain forbidden words
    if (cue.toLowerCase().includes('awesome') || cue.toLowerCase().includes('amazing')) {
      return res.json({ cue: getFallbackCue(phrase) });
    }
    
    res.json({ cue });
  } catch (error) {
    console.error('OpenAI API error:', error);
    res.json({ 
      cue: getFallbackCue(phrase),
      note: 'AI service unavailable. Using fallback response.'
    });
  }
});

// Fallback cue generator when AI is not available
function getFallbackCue(phrase) {
  const phraseLower = phrase.toLowerCase();
  
  // Common yoga poses with specific cues
  const poseCues = {
    'warrior i': 'Your back foot grounding and hip alignment in Warrior I is looking strong and steady.',
    'warrior ii': 'I love how your front knee is tracking beautifully over your ankle in Warrior II.',
    'warrior iii': 'Notice the wonderful line of energy from your fingertips through your back heel in Warrior III.',
    'virabhadrasana i': 'Your back foot grounding and hip alignment in Warrior I is looking strong and steady.',
    'virabhadrasana ii': 'I love how your front knee is tracking beautifully over your ankle in Warrior II.',
    'virabhadrasana iii': 'Notice the wonderful line of energy from your fingertips through your back heel in Warrior III.',
    'downward dog': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'down dog': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'adho mukha svanasana': 'Beautiful length through your spine - notice how your sit bones reach toward the sky in Downward Dog.',
    'tree': 'Your standing leg looks wonderfully grounded - feel that stability rising up through your spine in Tree Pose.',
    'vrksasana': 'Your standing leg looks wonderfully grounded - feel that stability rising up through your spine in Tree Pose.',
    'triangle': 'Excellent extension through both sides of your waist in Triangle - keep that beautiful length.',
    'trikonasana': 'Excellent extension through both sides of your waist in Triangle - keep that beautiful length.',
    'chair': 'Your weight is beautifully distributed through your heels in Chair Pose - feel that strength in your thighs.',
    'utkatasana': 'Your weight is beautifully distributed through your heels in Chair Pose - feel that strength in your thighs.',
    'cobra': 'Notice the elegant lift through your heart center in Cobra - shoulders drawing down beautifully.',
    'bhujangasana': 'Notice the elegant lift through your heart center in Cobra - shoulders drawing down beautifully.',
    'child': 'Your breath is flowing wonderfully in Child\'s Pose - let your hips sink back toward your heels.',
    'balasana': 'Your breath is flowing wonderfully in Child\'s Pose - let your hips sink back toward your heels.',
    'pigeon': 'Your hip alignment in Pigeon is looking balanced and steady - breathe into that stretch.',
    'eka pada rajakapotasana': 'Your hip alignment in Pigeon is looking balanced and steady - breathe into that stretch.',
    'crow': 'Wonderful engagement through your core in Crow - your gaze is focused and steady.',
    'bakasana': 'Wonderful engagement through your core in Crow - your gaze is focused and steady.',
    'plank': 'Your body is making one beautiful line from head to heels in Plank - strong core engagement.',
    'bridge': 'Notice how your thighs are parallel and your feet grounded in Bridge - beautiful lift through your hips.',
    'setu bandhasana': 'Notice how your thighs are parallel and your feet grounded in Bridge - beautiful lift through your hips.',
    'mountain': 'Your alignment in Mountain Pose is wonderfully tall - feel the energy rising through your crown.',
    'tadasana': 'Your alignment in Mountain Pose is wonderfully tall - feel the energy rising through your crown.',
    'corpse': 'Allow your body to completely release in Savasana - you\'ve done wonderful work today.',
    'savasana': 'Allow your body to completely release in Savasana - you\'ve done wonderful work today.'
  };

  // Check if any pose is mentioned in the phrase
  for (const [pose, cue] of Object.entries(poseCues)) {
    if (phraseLower.includes(pose)) {
      return cue;
    }
  }

  // Random pose cues for when no specific pose is mentioned
  const randomCues = [
    'Your alignment is looking wonderfully steady - notice how grounded your foundation feels.',
    'Beautiful breath awareness - let that steady inhale and exhale guide your movement.',
    'I love seeing your focused intention in this pose - your body is responding beautifully.',
    'Notice the elegant strength you\'re building - your form is looking balanced and centered.',
    'Your practice is showing wonderful progress - stay present with each breath.',
    'Feel how steady and grounded your stance is - that\'s excellent body awareness.',
    'Your dedication to proper form is evident - keep that mindful engagement.',
    'Notice the beautiful connection between your breath and movement today.'
  ];

  return randomCues[Math.floor(Math.random() * randomCues.length)];
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🧘 The Amazing Alternative to Awesome (AAA) is running on port ${PORT}`);
  console.log(`   Visit: http://localhost:${PORT}`);
});
