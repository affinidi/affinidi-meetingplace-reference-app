enum QuestionInputType { singleChips, multiChips, text, textMultiline }

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.inputType,
    this.options = const [],
    this.placeholder = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final QuestionInputType inputType;
  final List<String> options;
  final String placeholder;

  static const List<OnboardingQuestion> all = [
    // ── Layer 2: declarative knowledge ──────────────────────────────────────
    OnboardingQuestion(
      id: 'role',
      title: 'Your role',
      subtitle: 'What is your professional role? Your representative will use this as context.',
      inputType: QuestionInputType.text,
      placeholder: 'e.g. Senior Engineer at Acme / Product Lead / Founder & CEO',
    ),
    OnboardingQuestion(
      id: 'expertise',
      title: 'Areas of expertise',
      subtitle: 'Select every domain you work in. Your agent will draw on this knowledge.',
      inputType: QuestionInputType.multiChips,
      options: [
        'Identity & SSI',
        'Verifiable Credentials',
        'Privacy & Data',
        'Flutter / Mobile',
        'AWS / Cloud',
        'Node.js / TypeScript',
        'Python',
        'Product Management',
        'UX & Design',
        'AI / ML',
        'APIs & Integrations',
        'DevOps',
        'Blockchain / Web3',
      ],
    ),
    OnboardingQuestion(
      id: 'currentFocus',
      title: 'Current focus',
      subtitle: 'Briefly describe what you are working on right now.',
      inputType: QuestionInputType.textMultiline,
      placeholder:
          'e.g. Building an AI representative app using Affinidi Trust Fabric to issue agent configuration VCs…',
    ),
    // ── Layer 1: behavioural style ───────────────────────────────────────────
    OnboardingQuestion(
      id: 'tone',
      title: 'Communication style',
      subtitle: 'Select everything that describes how you typically write messages.',
      inputType: QuestionInputType.multiChips,
      options: [
        'Friendly',
        'Professional',
        'Direct',
        'Warm',
        'Casual',
        'Humorous',
        'Concise',
      ],
    ),
    OnboardingQuestion(
      id: 'formality',
      title: 'How formal are you?',
      subtitle: 'Think about your typical work or professional conversations.',
      inputType: QuestionInputType.singleChips,
      options: ['Very casual', 'Casual', 'Balanced', 'Formal', 'Very formal'],
    ),
    OnboardingQuestion(
      id: 'responseLength',
      title: 'Response length',
      subtitle: 'How long are your typical replies?',
      inputType: QuestionInputType.singleChips,
      options: ['Short & punchy', 'Medium length', 'Detailed & thorough'],
    ),
    OnboardingQuestion(
      id: 'emojiUsage',
      title: 'Emoji usage',
      subtitle: 'How often do emojis appear in your messages?',
      inputType: QuestionInputType.singleChips,
      options: ['Never', 'Rarely', 'Sometimes', 'Often'],
    ),
    OnboardingQuestion(
      id: 'greetingStyle',
      title: 'Your greeting',
      subtitle: 'How do you typically open a message?',
      inputType: QuestionInputType.text,
      placeholder: 'e.g. Hey! / Hi there, / Good morning,',
    ),
    OnboardingQuestion(
      id: 'signOff',
      title: 'Your sign-off',
      subtitle: 'How do you typically end a message?',
      inputType: QuestionInputType.text,
      placeholder: 'e.g. Thanks! / Cheers / Talk soon',
    ),
    OnboardingQuestion(
      id: 'sampleResponse',
      title: 'Write like yourself',
      subtitle:
          '"Hey, are you free for a quick call tomorrow?" — reply exactly as you would.',
      inputType: QuestionInputType.textMultiline,
      placeholder: 'Type your reply here…',
    ),
    OnboardingQuestion(
      id: 'hardLimits',
      title: 'Off-limits topics',
      subtitle: 'What should your AI representative never discuss on your behalf?',
      inputType: QuestionInputType.multiChips,
      options: [
        'Financial decisions',
        'Personal matters',
        'Medical topics',
        'Legal matters',
        'Nothing — handle it all',
      ],
    ),
  ];
}
