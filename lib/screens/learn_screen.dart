import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════
// LEARN SCREEN
// ══════════════════════════════════════════════════════
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  int _selectedSubCategory = 0;
  int _xp = 240;
  int _streak = 5;
  Set<String> _learnedSigns = {};
  final FlutterTts _tts = FlutterTts();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Kids',
      'icon': Icons.child_care,
      'color': const Color(0xFFFFC107),
    },
    {'label': 'ISL', 'icon': Icons.language, 'color': const Color(0xFFFF6D00)},
    {
      'label': 'ASL',
      'icon': Icons.sign_language,
      'color': const Color(0xFF00BCD4),
    },
    {
      'label': 'Situations',
      'icon': Icons.place,
      'color': const Color(0xFF7C4DFF),
    },
    {
      'label': 'Stories',
      'icon': Icons.auto_stories,
      'color': const Color(0xFF9C27B0),
    },
    {
      'label': 'SoundSense',
      'icon': Icons.hearing,
      'color': const Color(0xFFFF5252),
    },
  ];

  final List<String> _kidsSubCategories = [
    'Animals',
    'Colors',
    'Family',
    'Feelings',
  ];

  final Map<String, List<Map<String, dynamic>>> _kidsData = {
    'Animals': [
      {
        'name': 'CAT',
        'emoji': '🐱',
        'how': 'Curl fingers like whiskers near cheeks',
        'fact': 'One of the most recognized animal signs!',
        'steps': [
          'Make a C shape near your cheek',
          'Pull outward like cat whiskers',
        ],
      },
      {
        'name': 'DOG',
        'emoji': '🐶',
        'how': 'Pat thigh twice then snap fingers',
        'fact': 'Same sign used in both ASL and ISL!',
        'steps': ['Pat your thigh twice', 'Then snap your fingers'],
      },
      {
        'name': 'ELEPHANT',
        'emoji': '🐘',
        'how': 'Swing arm from nose like a trunk',
        'fact': 'A fun sign kids love to do!',
        'steps': ['Place hand at nose', 'Swing arm downward like a trunk'],
      },
      {
        'name': 'BUTTERFLY',
        'emoji': '🦋',
        'how': 'Cross wrists and flap hands like wings',
        'fact': 'Beautiful sign that looks like flying!',
        'steps': [
          'Cross both wrists together',
          'Flap both hands like butterfly wings',
        ],
      },
      {
        'name': 'FISH',
        'emoji': '🐟',
        'how': 'Wave flat hand side to side like swimming',
        'fact': 'Mimics the movement of a fish!',
        'steps': ['Hold flat hand out', 'Wave it side to side smoothly'],
      },
      {
        'name': 'BIRD',
        'emoji': '🐦',
        'how': 'Open and close index finger and thumb near mouth like a beak',
        'fact': 'Looks just like a bird beak opening!',
        'steps': [
          'Bring index finger and thumb to mouth',
          'Open and close them like a beak',
        ],
      },
      {
        'name': 'RABBIT',
        'emoji': '🐰',
        'how': 'Hold up two fingers and wiggle them like bunny ears',
        'fact': 'The wiggling fingers look just like floppy ears!',
        'steps': [
          'Hold up index and middle finger',
          'Bend and wiggle them like rabbit ears',
        ],
      },
      {
        'name': 'LION',
        'emoji': '🦁',
        'how': 'Claw hand near face then sweep over head like mane',
        'fact': 'The sweeping motion shows the lions mane!',
        'steps': ['Make a claw shape near face', 'Sweep hand over top of head'],
      },
      {
        'name': 'MONKEY',
        'emoji': '🐒',
        'how': 'Scratch sides with bent fingers like a monkey',
        'fact': 'Mimics how monkeys scratch their sides!',
        'steps': ['Bend fingers into claws', 'Scratch both sides of your body'],
      },
      {
        'name': 'COW',
        'emoji': '🐄',
        'how': 'Y handshape twisted at temple like horns',
        'fact': 'The Y shape represents cow horns!',
        'steps': [
          'Make Y handshape with pinky and thumb',
          'Twist at your temple to show horns',
        ],
      },
    ],
    'Colors': [
      {
        'name': 'RED',
        'emoji': '🔴',
        'how': 'Point index finger to lips and move down',
        'fact': 'Red lips inspired this sign!',
        'steps': ['Point index finger to your lips', 'Brush downward slightly'],
      },
      {
        'name': 'BLUE',
        'emoji': '🔵',
        'how': 'Shake B hand at shoulder level',
        'fact': 'Letter B shaking = Blue!',
        'steps': [
          'Form letter B with fingers',
          'Shake hand side to side at shoulder',
        ],
      },
      {
        'name': 'GREEN',
        'emoji': '🟢',
        'how': 'Shake G hand at shoulder level',
        'fact': 'Letter G shaking = Green!',
        'steps': [
          'Form letter G with thumb and index',
          'Shake hand side to side',
        ],
      },
      {
        'name': 'YELLOW',
        'emoji': '🟡',
        'how': 'Shake Y hand at shoulder level',
        'fact': 'Letter Y shaking = Yellow!',
        'steps': [
          'Form Y shape with pinky and thumb',
          'Shake at shoulder level',
        ],
      },
      {
        'name': 'WHITE',
        'emoji': '⬜',
        'how': 'Open hand on chest pull outward closing fingers',
        'fact': 'Like pulling something white from your heart!',
        'steps': [
          'Place open hand flat on chest',
          'Pull outward while closing fingers',
        ],
      },
      {
        'name': 'BLACK',
        'emoji': '⬛',
        'how': 'Index finger brushes across forehead left to right',
        'fact': 'Drawing a line across the brow!',
        'steps': [
          'Extend index finger',
          'Brush across forehead from left to right',
        ],
      },
      {
        'name': 'ORANGE',
        'emoji': '🟠',
        'how': 'Squeeze fist near chin like squeezing an orange',
        'fact': 'Mimics squeezing orange juice!',
        'steps': ['Make a fist near chin', 'Open and close hand repeatedly'],
      },
      {
        'name': 'PINK',
        'emoji': '🌸',
        'how': 'P handshape brushed down on lips',
        'fact': 'Pink is shown near the lips just like red!',
        'steps': [
          'Form P with index and middle finger',
          'Brush downward on lips',
        ],
      },
    ],
    'Family': [
      {
        'name': 'MOM',
        'emoji': '👩',
        'how': 'Touch chin with open hand fingers spread',
        'fact': 'Female signs are made near the chin!',
        'steps': ['Spread all five fingers open', 'Tap thumb to chin twice'],
      },
      {
        'name': 'DAD',
        'emoji': '👨',
        'how': 'Touch forehead with open hand fingers spread',
        'fact': 'Male signs are made near the forehead!',
        'steps': [
          'Spread all five fingers open',
          'Tap thumb to forehead twice',
        ],
      },
      {
        'name': 'SISTER',
        'emoji': '👧',
        'how': 'Slide A hand along jaw from ear to chin',
        'fact': 'Combines female location with A handshape!',
        'steps': [
          'Make A handshape at ear level',
          'Slide down along jawline to chin',
        ],
      },
      {
        'name': 'BROTHER',
        'emoji': '👦',
        'how': 'Slide A hand along forehead from ear to center',
        'fact': 'Male version of sister sign!',
        'steps': [
          'Make A handshape at ear level',
          'Slide across forehead to center',
        ],
      },
      {
        'name': 'FRIEND',
        'emoji': '🤝',
        'how': 'Hook index fingers together and swap positions',
        'fact': 'Interlocking fingers = connected friends!',
        'steps': ['Hook index fingers together', 'Flip hands and hook again'],
      },
      {
        'name': 'BABY',
        'emoji': '👶',
        'how': 'Rock arms like cradling a baby',
        'fact': 'Universal rocking motion for a baby!',
        'steps': [
          'Cross arms in front of body',
          'Rock them gently side to side',
        ],
      },
      {
        'name': 'GRANDMA',
        'emoji': '👵',
        'how': 'Open 5 hand at chin move forward in two arcs',
        'fact': 'Two arcs show the generation gap!',
        'steps': [
          'Open hand at chin with thumb touching',
          'Move forward in two bouncing arcs',
        ],
      },
      {
        'name': 'GRANDPA',
        'emoji': '👴',
        'how': 'Open 5 hand at forehead move forward in two arcs',
        'fact': 'Same as grandma but from forehead!',
        'steps': [
          'Open hand at forehead with thumb touching',
          'Move forward in two bouncing arcs',
        ],
      },
    ],
    'Feelings': [
      {
        'name': 'HAPPY',
        'emoji': '😊',
        'how': 'Brush open hand upward on chest twice',
        'fact': 'Lifting motion shows positive feeling!',
        'steps': ['Place flat hand on chest', 'Brush upward twice quickly'],
      },
      {
        'name': 'SAD',
        'emoji': '😢',
        'how': 'Pull both hands slowly down face',
        'fact': 'Hands trace the path of tears!',
        'steps': [
          'Hold both open hands in front of face',
          'Slowly pull them downward',
        ],
      },
      {
        'name': 'ANGRY',
        'emoji': '😠',
        'how': 'Claw both hands near face scrunch face',
        'fact': 'Tension in hands shows anger!',
        'steps': [
          'Claw both hands with bent fingers',
          'Hold near face with tense expression',
        ],
      },
      {
        'name': 'LOVE',
        'emoji': '❤️',
        'how': 'Cross both arms over chest like a hug',
        'fact': 'Universal gesture for love!',
        'steps': [
          'Cross both arms over your chest',
          'Hold or squeeze slightly',
        ],
      },
      {
        'name': 'SCARED',
        'emoji': '😨',
        'how': 'Both hands push toward chest quickly',
        'fact': 'Hands rushing to protect the body!',
        'steps': [
          'Hold both hands out to sides',
          'Quickly bring them to chest',
        ],
      },
      {
        'name': 'TIRED',
        'emoji': '😴',
        'how': 'Bent hands drop down from chest showing exhaustion',
        'fact': 'The drooping shows energy draining away!',
        'steps': [
          'Hold bent open hands on chest',
          'Let them drop downward with slumped shoulders',
        ],
      },
      {
        'name': 'EXCITED',
        'emoji': '🤩',
        'how': 'Alternating middle fingers brush up on chest',
        'fact': 'The alternating motion shows bubbling excitement!',
        'steps': [
          'Extend middle fingers of both hands',
          'Alternate brushing them up on chest',
        ],
      },
    ],
  };

  final List<Map<String, dynamic>> _islData = [
    {
      'name': 'NAMASTE',
      'emoji': '🙏',
      'how': 'Press palms together in prayer position',
      'difficulty': 'Easy',
      'fact': 'The most universal Indian greeting!',
      'steps': [
        'Bring both palms together',
        'Hold at chest level and bow slightly',
      ],
    },
    {
      'name': 'CHAI',
      'emoji': '☕',
      'how': 'Mime holding a small cup and drinking',
      'difficulty': 'Easy',
      'fact': 'Indias favorite beverage has its own sign!',
      'steps': [
        'Curl fingers like holding a small cup',
        'Bring to lips and tilt like drinking',
      ],
    },
    {
      'name': 'ROTI',
      'emoji': '🫓',
      'how': 'Mime rolling dough with both hands',
      'difficulty': 'Easy',
      'fact': 'Rolling motion mimics making roti!',
      'steps': [
        'Place one palm on the other',
        'Roll them in circular motion like dough',
      ],
    },
    {
      'name': 'SCHOOL',
      'emoji': '🏫',
      'how': 'Clap twice then hold flat hands parallel',
      'difficulty': 'Medium',
      'fact': 'ISL school sign is unique to India!',
      'steps': [
        'Clap hands twice',
        'Hold both flat hands parallel facing each other',
      ],
    },
    {
      'name': 'FAMILY',
      'emoji': '👨‍👩‍👧',
      'how': 'F handshape in both hands circle forward',
      'difficulty': 'Medium',
      'fact': 'Circle represents togetherness of family!',
      'steps': [
        'Form F handshape with both hands',
        'Move both hands in a circle forward',
      ],
    },
    {
      'name': 'RUPEE',
      'emoji': '₹',
      'how': 'R handshape brush down across palm',
      'difficulty': 'Easy',
      'fact': 'Unique to Indian Sign Language!',
      'steps': [
        'Make R handshape with crossed fingers',
        'Brush downward across your open palm',
      ],
    },
    {
      'name': 'TRAIN',
      'emoji': '🚂',
      'how': 'Mime train moving on rails with both hands',
      'difficulty': 'Easy',
      'fact': 'Trains are central to Indian life!',
      'steps': [
        'Hold both hands flat like train tracks',
        'Move one forward and back like train wheels',
      ],
    },
    {
      'name': 'MARKET',
      'emoji': '🛒',
      'how': 'Mime exchanging items between hands',
      'difficulty': 'Medium',
      'fact': 'Exchange gesture represents buying/selling!',
      'steps': [
        'Hold one item in each hand',
        'Exchange them back and forth between hands',
      ],
    },
    {
      'name': 'INDIA',
      'emoji': '🇮🇳',
      'how': 'I handshape tapped on opposite palm twice',
      'difficulty': 'Easy',
      'fact': 'Simple and proud sign for our nation!',
      'steps': [
        'Form I handshape with pinky finger up',
        'Tap it on your opposite open palm twice',
      ],
    },
    {
      'name': 'WATER',
      'emoji': '💧',
      'how': 'W handshape tapped to chin twice',
      'difficulty': 'Easy',
      'fact': 'Same in both ISL and ASL!',
      'steps': [
        'Form W with three fingers spread',
        'Tap lightly to your chin twice',
      ],
    },
    {
      'name': 'FOOD',
      'emoji': '🍛',
      'how': 'Bring fingertips to mouth repeatedly',
      'difficulty': 'Easy',
      'fact': 'Universal sign understood everywhere!',
      'steps': [
        'Bring all fingertips together',
        'Move toward mouth two to three times',
      ],
    },
    {
      'name': 'HOME',
      'emoji': '🏠',
      'how': 'Fingertips touch cheek twice moving back',
      'difficulty': 'Easy',
      'fact': 'Touching the face shows personal space!',
      'steps': [
        'Bring flat O fingertips to cheek',
        'Tap cheek then move back slightly',
      ],
    },
  ];

  final List<Map<String, dynamic>> _aslData = [
    {
      'name': 'HELLO',
      'emoji': '👋',
      'how': 'Open hand wave from forehead outward',
      'difficulty': 'Easy',
      'fact': 'Like saluting with a wave!',
      'steps': [
        'Raise open hand to forehead',
        'Wave it outward away from forehead',
      ],
    },
    {
      'name': 'THANK YOU',
      'emoji': '🙏',
      'how': 'Flat hand from chin moves forward and down',
      'difficulty': 'Easy',
      'fact': 'Blowing a kiss of gratitude!',
      'steps': [
        'Touch flat hand to your chin',
        'Move hand forward and slightly downward',
      ],
    },
    {
      'name': 'PLEASE',
      'emoji': '🤲',
      'how': 'Flat hand circles clockwise on chest',
      'difficulty': 'Easy',
      'fact': 'Heart area = sincere request!',
      'steps': ['Place flat open hand on chest', 'Move in clockwise circles'],
    },
    {
      'name': 'SORRY',
      'emoji': '😔',
      'how': 'A handshape circles on chest',
      'difficulty': 'Easy',
      'fact': 'Fist over heart = sincere apology!',
      'steps': [
        'Make A handshape with closed fist',
        'Circle fist on your chest',
      ],
    },
    {
      'name': 'YES',
      'emoji': '✅',
      'how': 'A handshape nods up and down',
      'difficulty': 'Easy',
      'fact': 'Like a nodding head!',
      'steps': [
        'Make A handshape with closed fist',
        'Nod fist up and down like a head',
      ],
    },
    {
      'name': 'NO',
      'emoji': '❌',
      'how': 'Index and middle finger close onto thumb',
      'difficulty': 'Easy',
      'fact': 'Like a talking mouth saying NO!',
      'steps': [
        'Extend index and middle fingers with thumb out',
        'Snap them down onto thumb',
      ],
    },
    {
      'name': 'GOOD',
      'emoji': '👍',
      'how': 'Flat hand from chin moves to other palm',
      'difficulty': 'Easy',
      'fact': 'Presenting goodness forward!',
      'steps': [
        'Touch flat hand to chin',
        'Move it forward to land on other open palm',
      ],
    },
    {
      'name': 'STOP',
      'emoji': '✋',
      'how': 'Chop edge of hand onto other palm',
      'difficulty': 'Easy',
      'fact': 'Sharp chop = sharp stop!',
      'steps': [
        'Hold non-dominant hand flat palm up',
        'Chop dominant hand edge onto it firmly',
      ],
    },
    {
      'name': 'HELP',
      'emoji': '🆘',
      'how': 'Thumb up fist on flat palm lift both up',
      'difficulty': 'Easy',
      'fact': 'Most important sign to know!',
      'steps': [
        'Place thumb up fist on flat open palm',
        'Lift both hands upward together',
      ],
    },
    {
      'name': 'WATER',
      'emoji': '💧',
      'how': 'W handshape tapped to chin twice',
      'difficulty': 'Easy',
      'fact': 'W stands for Water!',
      'steps': [
        'Form W with three spread fingers',
        'Tap lightly to chin twice',
      ],
    },
    {
      'name': 'I LOVE YOU',
      'emoji': '🤟',
      'how': 'Pinky index and thumb extended together',
      'difficulty': 'Easy',
      'fact': 'Most famous sign in the world!',
      'steps': [
        'Extend pinky, index finger and thumb',
        'Hold up facing outward — thats it!',
      ],
    },
    {
      'name': 'MORE',
      'emoji': '➕',
      'how': 'Bring flat O hands together tapping fingertips',
      'difficulty': 'Easy',
      'fact': 'Gathering more together!',
      'steps': [
        'Make flat O with both hands',
        'Tap fingertips of both hands together',
      ],
    },
  ];

  final List<Map<String, dynamic>> _situationsData = [
    {
      'name': 'Hospital',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFFF5252),
      'count': 8,
      'signs': [
        {
          'name': 'PAIN',
          'how': 'Tap fingers together at hurt area repeatedly',
          'fact': 'Used to tell doctors where it hurts!',
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!',
        },
        {
          'name': 'DOCTOR',
          'how': 'Tap wrist with two fingers like pulse check',
          'fact': 'Mimics checking a patients pulse!',
        },
        {
          'name': 'HELP',
          'how': 'Thumb up fist on flat palm lift both up',
          'fact': 'Most important emergency sign!',
        },
        {
          'name': 'MEDICINE',
          'how': 'Middle finger circles on opposite palm',
          'fact': 'Represents mixing medicine!',
        },
        {
          'name': 'TOILET',
          'how': 'Shake T handshape side to side',
          'fact': 'T = Toilet shaking = movement!',
        },
        {
          'name': 'NURSE',
          'how': 'Tap N handshape on wrist twice',
          'fact': 'Similar to doctor but with N!',
        },
        {
          'name': 'BED',
          'how': 'Tilt head onto praying hands',
          'fact': 'Mimics sleeping on a pillow!',
        },
      ],
    },
    {
      'name': 'School',
      'icon': Icons.school,
      'color': const Color(0xFF2196F3),
      'count': 6,
      'signs': [
        {
          'name': 'HELLO',
          'how': 'Open hand wave from forehead outward',
          'fact': 'Universal greeting sign!',
        },
        {
          'name': 'SORRY',
          'how': 'A handshape circles on chest',
          'fact': 'Fist over heart = sincere apology!',
        },
        {
          'name': 'PLEASE',
          'how': 'Flat hand circles clockwise on chest',
          'fact': 'Heart area = sincere request!',
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward',
          'fact': 'Blowing a kiss of gratitude!',
        },
        {
          'name': 'YES',
          'how': 'A handshape nods up and down',
          'fact': 'Like a nodding head!',
        },
        {
          'name': 'NO',
          'how': 'Index and middle finger close onto thumb',
          'fact': 'Like a talking mouth!',
        },
      ],
    },
    {
      'name': 'Home',
      'icon': Icons.home,
      'color': const Color(0xFF4CAF50),
      'count': 5,
      'signs': [
        {
          'name': 'FOOD',
          'how': 'Bring fingertips to mouth repeatedly',
          'fact': 'Hand goes to mouth like eating!',
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!',
        },
        {
          'name': 'SLEEP',
          'how': 'Pull open hand down over face closing eyes',
          'fact': 'Hand closing = eyes closing!',
        },
        {
          'name': 'LOVE',
          'how': 'Cross both arms over chest like a hug',
          'fact': 'Universal gesture for love!',
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things together!',
        },
      ],
    },
    {
      'name': 'Emergency',
      'icon': Icons.emergency,
      'color': const Color(0xFFFF9800),
      'count': 6,
      'signs': [
        {
          'name': 'HELP',
          'how': 'Thumb up fist on flat palm lift both up',
          'fact': 'Most important emergency sign!',
        },
        {
          'name': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
          'fact': 'Sharp motion = sharp stop!',
        },
        {
          'name': 'POLICE',
          'how': 'C handshape tapped to badge area on chest',
          'fact': 'C = Cop badge location!',
        },
        {
          'name': 'FIRE',
          'how': 'Wiggle all fingers pointing upward',
          'fact': 'Fingers look like rising flames!',
        },
        {
          'name': 'DANGER',
          'how': 'A handshape sweeps up from under other hand',
          'fact': 'Rising motion = rising danger!',
        },
        {
          'name': 'SOS',
          'how': 'Tap 3 dots 3 dashes 3 dots on your palm',
          'fact': 'Morse code SOS in sign language!',
        },
      ],
    },
    {
      'name': 'Market',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFF9C27B0),
      'count': 5,
      'signs': [
        {
          'name': 'MONEY',
          'how': 'Tap back of flat O hand into upturned palm',
          'fact': 'Like counting bills!',
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things!',
        },
        {
          'name': 'GOOD',
          'how': 'Flat hand from chin moves to other palm',
          'fact': 'Presenting goodness forward!',
        },
        {
          'name': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
          'fact': 'Sharp chop = sharp stop!',
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
          'fact': 'Blowing a kiss of gratitude!',
        },
      ],
    },
    {
      'name': 'Restaurant',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFFC107),
      'count': 5,
      'signs': [
        {
          'name': 'FOOD',
          'how': 'Bring fingertips to mouth repeatedly',
          'fact': 'Hand goes to mouth like eating!',
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!',
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things!',
        },
        {
          'name': 'GOOD',
          'how': 'Flat hand from chin moves to other palm',
          'fact': 'Presenting goodness forward!',
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
          'fact': 'Blowing a kiss of gratitude!',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _storiesData = [
    {
      'title': 'Ravi goes to Hospital',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFFF5252),
      'signs': ['PAIN', 'HELP', 'DOCTOR', 'WATER', 'MEDICINE'],
      'time': '5 mins',
      'xp': 50,
      'scenes': [
        {
          'scene': 'Ravi wakes up feeling unwell',
          'sign': 'PAIN',
          'how': 'Tap fingers together at the hurt area repeatedly',
        },
        {
          'scene': 'Ravi calls out for help',
          'sign': 'HELP',
          'how': 'Place thumb up fist on flat palm and lift both hands up',
        },
        {
          'scene': 'The doctor examines Ravi',
          'sign': 'DOCTOR',
          'how': 'Tap wrist with middle and index fingers like checking pulse',
        },
        {
          'scene': 'Nurse brings water for Ravi',
          'sign': 'WATER',
          'how': 'W handshape tapped to chin twice',
        },
        {
          'scene': 'Doctor gives Ravi medicine',
          'sign': 'MEDICINE',
          'how': 'Rub middle finger in circle on opposite palm',
        },
      ],
    },
    {
      'title': 'Priya at School',
      'icon': Icons.school,
      'color': const Color(0xFF2196F3),
      'signs': ['HELLO', 'PLEASE', 'THANK YOU', 'YES', 'HAPPY', 'HOME'],
      'time': '6 mins',
      'xp': 60,
      'scenes': [
        {
          'scene': 'Priya greets her friends at school',
          'sign': 'HELLO',
          'how': 'Open hand wave from forehead outward',
        },
        {
          'scene': 'Teacher asks Priya to sit down',
          'sign': 'PLEASE',
          'how': 'Flat hand circles clockwise on chest',
        },
        {
          'scene': 'Priya thanks her teacher',
          'sign': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
        },
        {
          'scene': 'Friend asks a yes or no question',
          'sign': 'YES',
          'how': 'A handshape nods up and down like nodding head',
        },
        {
          'scene': 'Priya feels great today',
          'sign': 'HAPPY',
          'how': 'Brush open hand upward on chest twice',
        },
        {
          'scene': 'School ends time to go home',
          'sign': 'HOME',
          'how': 'Fingertips touch cheek twice moving back',
        },
      ],
    },
    {
      'title': 'Family Dinner',
      'icon': Icons.dinner_dining,
      'color': const Color(0xFF4CAF50),
      'signs': ['FOOD', 'WATER', 'MORE', 'LOVE'],
      'time': '4 mins',
      'xp': 40,
      'scenes': [
        {
          'scene': 'Family gathers for dinner together',
          'sign': 'FOOD',
          'how': 'Bring fingertips to mouth repeatedly',
        },
        {
          'scene': 'Mom pours water for everyone',
          'sign': 'WATER',
          'how': 'W handshape tapped to chin twice',
        },
        {
          'scene': 'Dad wants more rice please',
          'sign': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
        },
        {
          'scene': 'Family feels grateful and happy',
          'sign': 'LOVE',
          'how': 'Cross both arms over chest like a self hug',
        },
      ],
    },
    {
      'title': 'Emergency on Street',
      'icon': Icons.emergency,
      'color': const Color(0xFFFF9800),
      'signs': ['HELP', 'STOP', 'POLICE', 'DANGER', 'SOS'],
      'time': '5 mins',
      'xp': 50,
      'scenes': [
        {
          'scene': 'Someone falls on the street',
          'sign': 'HELP',
          'how': 'Thumb up fist on flat palm lift both hands up',
        },
        {
          'scene': 'Traffic must stop immediately',
          'sign': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
        },
        {
          'scene': 'Someone calls the police',
          'sign': 'POLICE',
          'how': 'C handshape tapped to badge area on chest',
        },
        {
          'scene': 'Warning others of danger ahead',
          'sign': 'DANGER',
          'how': 'A handshape sweeps up from under opposite hand',
        },
        {
          'scene': 'Sending emergency signal to helpers',
          'sign': 'SOS',
          'how': 'Tap 3 dots 3 dashes 3 dots on your palm',
        },
      ],
    },
    {
      'title': 'Shopping with Mom',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFF9C27B0),
      'signs': ['MONEY', 'MORE', 'GOOD', 'STOP', 'THANK YOU', 'HAPPY'],
      'time': '7 mins',
      'xp': 70,
      'scenes': [
        {
          'scene': 'Mom and child go to the market',
          'sign': 'MONEY',
          'how': 'Tap back of flat O hand into upturned palm',
        },
        {
          'scene': 'Child wants more snacks',
          'sign': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
        },
        {
          'scene': 'Mom finds a good price',
          'sign': 'GOOD',
          'how': 'Flat hand from chin moves forward into other palm',
        },
        {
          'scene': 'Mom says enough shopping today',
          'sign': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
        },
        {
          'scene': 'Shopkeeper helps them nicely',
          'sign': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
        },
        {
          'scene': 'Happy journey back home',
          'sign': 'HAPPY',
          'how': 'Brush open hand upward on chest twice',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _soundsData = [
    {
      'name': 'Bell Ringing',
      'icon': Icons.notifications_active,
      'color': const Color(0xFFFFC107),
      'pattern': [100, 50, 100, 50, 100],
      'intensities': [200, 0, 200, 0, 200],
    },
    {
      'name': 'Kids Shouting',
      'icon': Icons.child_care,
      'color': const Color(0xFFFF80AB),
      'pattern': [80, 40, 120, 30, 60, 50, 90],
      'intensities': [150, 0, 180, 0, 120, 0, 200],
    },
    {
      'name': 'Dog Barking',
      'icon': Icons.pets,
      'color': const Color(0xFF8D6E63),
      'pattern': [300, 200, 300, 200, 300],
      'intensities': [255, 0, 255, 0, 255],
    },
    {
      'name': 'Breaking Glass',
      'icon': Icons.broken_image,
      'color': const Color(0xFF64B5F6),
      'pattern': [500, 100, 50, 50, 50, 50],
      'intensities': [255, 0, 80, 0, 60, 0],
    },
    {
      'name': 'Emergency Siren',
      'icon': Icons.emergency,
      'color': const Color(0xFFFF5252),
      'pattern': [500, 300, 500, 300, 500],
      'intensities': [50, 0, 150, 0, 255],
    },
    {
      'name': 'Car Honk',
      'icon': Icons.directions_car,
      'color': const Color(0xFF90A4AE),
      'pattern': [200, 100, 200],
      'intensities': [255, 0, 255],
    },
    {
      'name': 'Rain',
      'icon': Icons.water_drop,
      'color': const Color(0xFF4FC3F7),
      'pattern': [50, 80, 30, 60, 40, 70],
      'intensities': [100, 0, 80, 0, 120, 0],
    },
    {
      'name': 'Fire Alarm',
      'icon': Icons.local_fire_department,
      'color': const Color(0xFFFF7043),
      'pattern': [200, 100, 200, 100, 200],
      'intensities': [255, 0, 255, 0, 255],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadProgress();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _xp = prefs.getInt('xp') ?? 240;
        _streak = prefs.getInt('streak') ?? 5;
        _learnedSigns = Set<String>.from(prefs.getStringList('learned') ?? []);
      });
    }
  }

  Future<void> _markLearned(String sign) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _learnedSigns.add(sign);
      _xp += 10;
    });
    await prefs.setStringList('learned', _learnedSigns.toList());
    await prefs.setInt('xp', _xp);
    HapticFeedback.mediumImpact();
  }

  void _switchCategory(int index) {
    _fadeController.reset();
    setState(() {
      _selectedCategory = index;
      _selectedSubCategory = 0;
    });
    _fadeController.forward();
  }

  void _openStory(Map<String, dynamic> story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryViewerScreen(story: story)),
    );
  }

  void _openSituationDetail(Map<String, dynamic> situation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (situation['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      situation['icon'] as IconData,
                      color: situation['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        situation['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${situation['count']} signs to learn',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFB0BEC5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: (situation['signs'] as List).length,
                itemBuilder: (context, i) {
                  final sign = (situation['signs'] as List)[i];
                  final isLearned = _learnedSigns.contains(sign['name']);
                  final color = situation['color'] as Color;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLearned
                            ? const Color(0xFF69F0AE).withOpacity(0.3)
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showSignAnimation(sign, color);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isLearned
                                    ? Icons.check_circle
                                    : Icons.sign_language,
                                color:
                                    isLearned ? const Color(0xFF69F0AE) : color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sign['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    sign['how'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFFB0BEC5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                for (int k = 0; k < 3; k++) {
                                  await _tts.speak(sign['name']);
                                  await Future.delayed(
                                    const Duration(milliseconds: 1200),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF7C4DFF).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF7C4DFF)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.volume_up,
                                        color: Color(0xFF7C4DFF), size: 18),
                                    Text('×3',
                                        style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            color: const Color(0xFF7C4DFF),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.play_circle_outline,
                                color: Color(0xFF6B6B6B), size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignAnimation(Map<String, dynamic> sign, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SignAnimationSheet(
          sign: sign,
          color: color,
          tts: _tts,
          onMarkLearned: () => _markLearned(sign['name']),
          isLearned: _learnedSigns.contains(sign['name']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'Learn & Sense',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text('$_streak Day Streak',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.orange)),
                  const SizedBox(width: 16),
                  const Icon(Icons.star_outline, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('$_xp XP',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.amber)),
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF69F0AE), size: 16),
                  const SizedBox(width: 4),
                  Text('${_learnedSigns.length} Learned',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFF69F0AE))),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCategoryScroll(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScroll() {
    return Container(
      height: 90,
      color: const Color(0xFF0A0A0A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _switchCategory(i);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (cat['color'] as Color).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      border: Border.all(
                        color: isSelected
                            ? cat['color'] as Color
                            : const Color(0xFF2A2A2A),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color:
                                      (cat['color'] as Color).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2)
                            ]
                          : [],
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: isSelected
                          ? cat['color'] as Color
                          : const Color(0xFF6B6B6B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['label'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isSelected
                          ? cat['color'] as Color
                          : const Color(0xFF6B6B6B),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedCategory) {
      case 0:
        return _buildKidsSection();
      case 1:
        return _buildISLSection();
      case 2:
        return _buildASLSection();
      case 3:
        return _buildSituationsSection();
      case 4:
        return _buildStoriesSection();
      case 5:
        return _buildSoundSenseSection();
      default:
        return _buildKidsSection();
    }
  }

  Widget _buildProgressWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "You've learned ${_learnedSigns.length} signs today!",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
              Text('$_xp XP',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.amber,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_xp % 200) / 200,
            backgroundColor: const Color(0xFF2A2A2A),
            color: const Color(0xFF00BCD4),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_xp % 200}/200 XP to next level',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFFB0BEC5))),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text('$_streak day streak',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.orange)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: color)),
    );
  }

  // ── FIX: childAspectRatio changed from 0.85 → 0.72 to prevent bottom overflow ──
  Widget _buildSignGrid({
    required List<Map<String, dynamic>> signs,
    required Color color,
    String? badgeKey,
    Color? badgeColor,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72, // ← FIXED: was 0.85, caused 18–19px overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: signs.length,
      itemBuilder: (context, i) {
        final sign = signs[i];
        final isLearned = _learnedSigns.contains(sign['name']);
        return GestureDetector(
          onTap: () => _showSignAnimation(sign, color),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isLearned ? color.withOpacity(0.6) : color.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: color.withOpacity(0.1),
                    child: Center(
                      child: Text(sign['emoji'] ?? '✋',
                          style: const TextStyle(fontSize: 56)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sign['name'],
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sign['how'],
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: const Color(0xFFB0BEC5)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          badgeKey != null && sign[badgeKey] != null
                              ? _buildBadge(sign[badgeKey],
                                  badgeColor ?? const Color(0xFF69F0AE))
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Text('+10 XP',
                                      style: GoogleFonts.poppins(
                                          fontSize: 9, color: color)),
                                ),
                          isLearned
                              ? Icon(Icons.check_circle, color: color, size: 16)
                              : Icon(Icons.play_circle_outline,
                                  color: color, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKidsSection() {
    final subCat = _kidsSubCategories[_selectedSubCategory];
    final signs = _kidsData[subCat] ?? [];
    const color = Color(0xFFFFC107);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learn Signs for Kids',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Tap any card to see the sign animation',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_kidsSubCategories.length, (i) {
                final isSelected = _selectedSubCategory == i;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedSubCategory = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected ? color : const Color(0xFF2A2A2A)),
                    ),
                    child: Text(
                      _kidsSubCategories[i],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                            isSelected ? Colors.black : const Color(0xFFB0BEC5),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _buildSignGrid(signs: signs, color: color),
          _buildProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildISLSection() {
    const color = Color(0xFFFF6D00);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indian Sign Language',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Container(color: const Color(0xFFFF6D00))),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: const Color(0xFF388E3C))),
              ],
            ),
          ),
          Text('Tap any card to see the sign animation',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 16),
          _buildSignGrid(
              signs: _islData,
              color: color,
              badgeKey: 'difficulty',
              badgeColor: const Color(0xFF69F0AE)),
          _buildProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildASLSection() {
    const color = Color(0xFF00BCD4);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('American Sign Language',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Tap any card to see the sign animation',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 16),
          _buildSignGrid(
              signs: _aslData,
              color: color,
              badgeKey: 'difficulty',
              badgeColor: const Color(0xFF69F0AE)),
          _buildProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildSituationsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Real Life Situations',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Learn signs for every situation',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _situationsData.length,
            itemBuilder: (context, i) {
              final sit = _situationsData[i];
              final learnedCount = (sit['signs'] as List)
                  .where((s) => _learnedSigns.contains(s['name']))
                  .length;
              final total = sit['count'] as int;
              return GestureDetector(
                onTap: () => _openSituationDetail(sit),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: (sit['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (sit['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(sit['icon'] as IconData,
                            color: sit['color'] as Color, size: 20),
                      ),
                      const Spacer(),
                      Text(sit['name'],
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('$total signs',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: const Color(0xFFB0BEC5))),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: total > 0 ? learnedCount / total : 0,
                        backgroundColor: const Color(0xFF2A2A2A),
                        color: sit['color'] as Color,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Text('$learnedCount/$total learned',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: const Color(0xFF6B6B6B))),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learn Through Stories',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Signs in real conversations',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 16),
          ..._storiesData.map((story) {
            return GestureDetector(
              onTap: () => _openStory(story),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (story['color'] as Color).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: (story['color'] as Color).withOpacity(0.15),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(story['icon'] as IconData,
                              color: story['color'] as Color, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(story['title'],
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color:
                                    (story['color'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('STORY',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: story['color'] as Color,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Signs used:',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFFB0BEC5))),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: (story['signs'] as List<String>)
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF252525),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFF3A3A3A)),
                                      ),
                                      child: Text(s,
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.white)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  color: Color(0xFF6B6B6B), size: 14),
                              const SizedBox(width: 4),
                              Text(story['time'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B6B6B))),
                              const SizedBox(width: 16),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text('${story['xp']} XP',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.amber)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF00BCD4),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text('Start Story',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          _buildProgressWidget(),
        ],
      ),
    );
  }

  Widget _buildSoundSenseSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feel Your World',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Sense sounds through vibration',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFFB0BEC5))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _soundsData.length,
            itemBuilder: (context, i) {
              final sound = _soundsData[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (sound['color'] as Color).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (sound['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(sound['icon'] as IconData,
                          color: sound['color'] as Color, size: 20),
                    ),
                    const Spacer(),
                    Text(sound['name'],
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => HapticFeedback.heavyImpact(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: (sound['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  (sound['color'] as Color).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.vibration,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Feel It',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.explore,
                          color: Color(0xFFFF5252), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Sound Compass',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Find where sounds come from',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: const Color(0xFFB0BEC5))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(painter: CompassPainter()),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: Color(0xFF90A4AE), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text('Probably a Car Honk (78%)',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white))),
                      Container(
                        width: 80,
                        height: 6,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: const Color(0xFF2A2A2A)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.78,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: const Color(0xFF00BCD4))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => HapticFeedback.mediumImpact(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Start Compass',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildProgressWidget(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// SIGN ANIMATION SHEET
// ══════════════════════════════════════════════════════
class _SignAnimationSheet extends StatefulWidget {
  final Map<String, dynamic> sign;
  final Color color;
  final FlutterTts tts;
  final VoidCallback onMarkLearned;
  final bool isLearned;

  const _SignAnimationSheet({
    required this.sign,
    required this.color,
    required this.tts,
    required this.onMarkLearned,
    required this.isLearned,
  });

  @override
  State<_SignAnimationSheet> createState() => _SignAnimationSheetState();
}

class _SignAnimationSheetState extends State<_SignAnimationSheet>
    with TickerProviderStateMixin {
  late AnimationController _handController;
  late Animation<double> _handAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAnimating = false;
  int _currentStep = 0;
  bool _learned = false;

  @override
  void initState() {
    super.initState();
    _learned = widget.isLearned;
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _handAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 300), _playAnimation);
  }

  @override
  void dispose() {
    _handController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _currentStep = 0;
    });
    HapticFeedback.lightImpact();
    final steps = widget.sign['steps'] as List? ?? ['Step 1', 'Step 2'];
    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      await _handController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      await _handController.reverse();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (mounted) setState(() => _isAnimating = false);
  }

  String _getHandEmoji(int step) {
    final name = widget.sign['name'] as String? ?? '';
    final Map<String, List<String>> handEmojis = {
      'CAT': ['🖐️', '✋'],
      'DOG': ['🤚', '🫰'],
      'ELEPHANT': ['🤙', '👋'],
      'BUTTERFLY': ['🙌', '👐'],
      'FISH': ['🤲', '✋'],
      'BIRD': ['🤏', '✌️'],
      'RABBIT': ['✌️', '🖖'],
      'LION': ['🦁', '🖐️'],
      'MONKEY': ['🫱', '🫲'],
      'COW': ['🤙', '🤙'],
      'HELLO': ['👋', '🙋'],
      'THANK YOU': ['🤲', '👋'],
      'PLEASE': ['🤲', '🙏'],
      'SORRY': ['✊', '🤜'],
      'YES': ['✊', '👊'],
      'NO': ['✌️', '🤞'],
      'GOOD': ['🤲', '👍'],
      'STOP': ['✋', '🖐️'],
      'HELP': ['👍', '🙌'],
      'WATER': ['🤟', '💧'],
      'I LOVE YOU': ['🤟', '❤️'],
      'MORE': ['🤌', '👌'],
      'NAMASTE': ['🙏', '🙏'],
      'CHAI': ['🫗', '☕'],
      'HAPPY': ['😊', '🙌'],
      'SAD': ['😢', '👐'],
      'LOVE': ['🤗', '❤️'],
      'PAIN': ['🤜', '💢'],
      'ANGRY': ['😠', '👊'],
      'ROTI': ['🤲', '🖐️'],
      'SCHOOL': ['👏', '🤲'],
      'FAMILY': ['🤟', '👨‍👩‍👧'],
      'RUPEE': ['✌️', '✋'],
      'TRAIN': ['🤲', '🚂'],
      'MARKET': ['🤝', '🛒'],
    };
    final emojis = handEmojis[name] ?? ['✋', '🤚'];
    return emojis[step % emojis.length];
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.sign['steps'] as List? ?? [];
    final emoji = widget.sign['emoji'] ?? '✋';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sign['name'],
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          widget.sign['how'] ?? '',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: const Color(0xFFB0BEC5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _isAnimating ? _pulseAnimation.value : 1.0,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.color.withOpacity(0.3)),
                    ),
                    child: AnimatedBuilder(
                      animation: _handAnimation,
                      builder: (_, __) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(_handAnimation.value * 20 - 10,
                                _handAnimation.value * -15),
                            child: Text(
                              _getHandEmoji(_currentStep),
                              style: TextStyle(
                                  fontSize: 60 + (_handAnimation.value * 10)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isAnimating && steps.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Step ${_currentStep + 1}: ${steps[_currentStep]}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: widget.color),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (!_isAnimating)
                            Text('Tap Play to see animation',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF6B6B6B))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (steps.isNotEmpty)
                Row(
                  children: List.generate(
                    steps.length,
                    (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 4,
                        decoration: BoxDecoration(
                          color: (_isAnimating && _currentStep == i)
                              ? widget.color
                              : widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              if (steps.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How to sign:',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: widget.color,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...List.generate(
                          steps.length,
                          (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                          color: widget.color.withOpacity(0.15),
                                          shape: BoxShape.circle),
                                      child: Center(
                                        child: Text('${i + 1}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: widget.color,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(steps[i],
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.white))),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              if (widget.sign['fact'] != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD740).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFFFD740).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.sign['fact'],
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFFD740),
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _playAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isAnimating ? Icons.stop : Icons.play_arrow,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              _isAnimating ? 'Playing...' : 'Play Animation',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.tts.speak(widget.sign['name']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF7C4DFF).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.volume_up,
                          color: Color(0xFF7C4DFF), size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (!_learned) {
                        widget.onMarkLearned();
                        setState(() => _learned = true);
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: _learned
                            ? const Color(0xFF69F0AE).withOpacity(0.15)
                            : const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _learned
                                ? const Color(0xFF69F0AE).withOpacity(0.4)
                                : const Color(0xFF3A3A3A)),
                      ),
                      child: Icon(
                        _learned
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: _learned
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFF6B6B6B),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// STORY VIEWER SCREEN
// ══════════════════════════════════════════════════════
class StoryViewerScreen extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryViewerScreen({super.key, required this.story});
  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _currentScene = 0;

  @override
  Widget build(BuildContext context) {
    final scenes = widget.story['scenes'] as List;
    final scene = scenes[_currentScene];
    final color = widget.story['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.story['title'],
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                scenes.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentScene ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentScene ? color : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: Icon(widget.story['icon'] as IconData,
                          color: color, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text('Scene ${_currentScene + 1}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF6B6B6B))),
                    const SizedBox(height: 8),
                    Text(scene['scene'],
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: const Color(0xFFB0BEC5)),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Text(scene['sign'],
                        style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00BCD4))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(scene['how'],
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_currentScene > 0)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentScene--),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 16),
                            Text('Previous',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_currentScene > 0) const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_currentScene < scenes.length - 1) {
                        setState(() => _currentScene++);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentScene < scenes.length - 1
                                ? 'Next Scene'
                                : 'Finish Story',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentScene < scenes.length - 1
                                ? Icons.arrow_forward_ios
                                : Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// COMPASS PAINTER
// ══════════════════════════════════════════════════════
class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
        center,
        radius - 4,
        Paint()
          ..color = const Color(0xFF2A2A2A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(
        center,
        radius * 0.3,
        Paint()
          ..color = const Color(0xFFFF5252).withOpacity(0.2)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        center,
        radius * 0.3,
        Paint()
          ..color = const Color(0xFFFF5252).withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    final arrowPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center, Offset(center.dx + radius * 0.6, center.dy), arrowPaint);
    canvas.drawLine(
        Offset(center.dx + radius * 0.6, center.dy),
        Offset(center.dx + radius * 0.45, center.dy - radius * 0.12),
        arrowPaint);
    canvas.drawLine(
        Offset(center.dx + radius * 0.6, center.dy),
        Offset(center.dx + radius * 0.45, center.dy + radius * 0.12),
        arrowPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final item in [
      {'label': 'N', 'x': center.dx - 6, 'y': 4.0},
      {'label': 'S', 'x': center.dx - 6, 'y': size.height - 20.0},
      {'label': 'W', 'x': 4.0, 'y': center.dy - 8},
      {'label': 'E', 'x': size.width - 16.0, 'y': center.dy - 8},
    ]) {
      textPainter.text = TextSpan(
        text: item['label'] as String,
        style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 12,
            fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(item['x'] as double, item['y'] as double));
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}
