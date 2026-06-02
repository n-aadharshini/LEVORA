import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

const Map<String, String> kSignVideoAssets = {
  'CAT': 'assets/videos/VDOS/CAT.mp4',
  'DEAR': 'assets/videos/VDOS/DEAR.mp4',
  'HORSE': 'assets/videos/VDOS/HORSE.mp4',
  'OX': 'assets/videos/VDOS/OX.mp4',
  'PENGUIN': 'assets/videos/VDOS/PENGUIN.mp4',
  'PANDA': 'assets/videos/VDOS/PANDA.mp4',
  'RAINO': 'assets/videos/VDOS/RAINO.mp4',
  'COW': 'assets/videos/VDOS/COW.mp4',
  'BIRD': 'assets/videos/VDOS/BIRD.mp4',
  'ELEPHANT': 'assets/videos/VDOS/ELEPHANT.mp4',
  'RED': 'assets/videos/VDOS/RED.mp4',
  'BLUE': 'assets/videos/VDOS/BLUE.mp4',
  'GREEN': 'assets/videos/VDOS/GREEN.mp4',
  'YELLOW': 'assets/videos/VDOS/YELLOW.mp4',
  'WHITE': 'assets/videos/VDOS/WHITE.mp4',
  'BLACK': 'assets/videos/VDOS/BLACK.mp4',
  'ORANGE': 'assets/videos/VDOS/ORANGE.mp4',
  'PINK': 'assets/videos/VDOS/PINK.mp4',
  'MOM': 'assets/videos/VDOS/MOTHER.mp4',
  'DAD': 'assets/videos/VDOS/FATHER.mp4',
  'SISTER': 'assets/videos/VDOS/SISTER.mp4',
  'BROTHER': 'assets/videos/VDOS/BROTHER.mp4',
  'FRIEND': 'assets/videos/VDOS/FRND.mp4',
  'BABY': 'assets/videos/VDOS/BBY.mp4',
  'GRANDMA': 'assets/videos/VDOS/GRANDMOTHER.mp4',
  'GRANDPA': 'assets/videos/VDOS/GRANDFATHER.mp4',
  'HAPPY': 'assets/videos/VDOS/HAPPY.mp4',
  'SAD': 'assets/videos/VDOS/SAD.mp4',
  'ANGRY': 'assets/videos/VDOS/ANGERY.mp4',
  'BOARD': 'assets/videos/VDOS/BOARD.mp4',
  'BUZY': 'assets/videos/VDOS/BUZY.mp4',
  'TIRED': 'assets/videos/VDOS/TIRED.mp4',
  'EXCITED': 'assets/videos/VDOS/EXCITED.mp4',
  'NAMASTE': 'assets/videos/VDOS/ISL NAMASTAE.mp4',
  'BYE': 'assets/videos/VDOS/ISL BYE.mp4',
  'AGAIN': 'assets/videos/VDOS/ISL AGAIN.mp4',
  'HE': 'assets/videos/VDOS/ISL HE.mp4',
  'HELLO': 'assets/videos/VDOS/ISL HELLO.mp4',
  'INDIAN': 'assets/videos/VDOS/ISL INDIAN.mp4',
  'ME': 'assets/videos/VDOS/ISL ME.mp4',
  'PLEASE': 'assets/videos/VDOS/ISL PLEASE.mp4',
  'SHE': 'assets/videos/VDOS/ISL SHE.mp4',
  'SORRY': 'assets/videos/VDOS/ISL SORRY.mp4',
  'THANKYOU': 'assets/videos/VDOS/ISL THANKYOU.mp4',
  'WELCOME': 'assets/videos/VDOS/ISL WELCOME.mp4',
  'ASL_HELLO': 'assets/videos/VDOS/HELLO.mp4',
  'FORGET': 'assets/videos/VDOS/FORGET.mp4',
  'ASL_EXCITED': 'assets/videos/VDOS/EXCITED.mp4',
  'WRONG': 'assets/videos/VDOS/WRONG.mp4',
  'NEED': 'assets/videos/VDOS/NEED.mp4',
  'NO': 'assets/videos/VDOS/NO.mp4',
  'WHAT': 'assets/videos/VDOS/WHAT.mp4',
  'WORK': 'assets/videos/VDOS/WORK.mp4',
  'COME': 'assets/videos/VDOS/COME.mp4',
  'INTRODUCE': 'assets/videos/VDOS/INTRODUCE.mp4',
  'NOTHING': 'assets/videos/VDOS/NTHG.mp4',
  'HARD OF EARING': 'assets/videos/VDOS/HARD OF EARING.mp4',
};

const List<Map<String, String>> kISLAlphabet = [
  {
    'letter': 'A',
    'hand': '✊',
    'desc': 'Closed fist, thumb to side',
    'fact': 'A is the same in ISL and ASL!'
  },
  {
    'letter': 'B',
    'hand': '🖐️',
    'desc': 'Four fingers up, thumb folded across palm',
    'fact': 'B looks like a flat board!'
  },
  {
    'letter': 'C',
    'hand': '🤏',
    'desc': 'Curved hand open like the letter C',
    'fact': 'C mimics the curve of the letter!'
  },
  {
    'letter': 'D',
    'hand': '👆',
    'desc': 'Index up, other fingers touch thumb',
    'fact': 'D forms a loop like the letter!'
  },
  {
    'letter': 'E',
    'hand': '🤞',
    'desc': 'Fingers bent, thumb tucked under',
    'fact': 'E looks like curled fingers!'
  },
  {
    'letter': 'F',
    'hand': '👌',
    'desc': 'Index and thumb touch, other fingers up',
    'fact': 'F forms a circle and three lines!'
  },
  {
    'letter': 'G',
    'hand': '👉',
    'desc': 'Index and thumb point sideways',
    'fact': 'G points like a gun shape!'
  },
  {
    'letter': 'H',
    'hand': '✌️',
    'desc': 'Index and middle finger together, pointing out',
    'fact': 'H = two fingers side by side!'
  },
  {
    'letter': 'I',
    'hand': '🤙',
    'desc': 'Pinky finger raised, fist closed',
    'fact': 'I stands alone — like the letter!'
  },
  {
    'letter': 'J',
    'hand': '🤙',
    'desc': 'Pinky traces a J shape in the air',
    'fact': 'J is drawn in the air!'
  },
  {
    'letter': 'K',
    'hand': '✌️',
    'desc': 'Index up, middle angled out, thumb between',
    'fact': 'K has a unique three-finger shape!'
  },
  {
    'letter': 'L',
    'hand': '🤙',
    'desc': 'Index up, thumb out — L shape',
    'fact': 'L looks exactly like the letter!'
  },
  {
    'letter': 'M',
    'hand': '✊',
    'desc': 'Three fingers folded over thumb',
    'fact': 'M = three humps covered by fingers!'
  },
  {
    'letter': 'N',
    'hand': '✊',
    'desc': 'Two fingers folded over thumb',
    'fact': 'N = two humps!'
  },
  {
    'letter': 'O',
    'hand': '👌',
    'desc': 'All fingers and thumb form a circle',
    'fact': 'O is a perfect circle!'
  },
  {
    'letter': 'P',
    'hand': '👇',
    'desc': 'K handshape pointing downward',
    'fact': 'P is K flipped down!'
  },
  {
    'letter': 'Q',
    'hand': '👇',
    'desc': 'G handshape pointing downward',
    'fact': 'Q is G pointing down!'
  },
  {
    'letter': 'R',
    'hand': '🤞',
    'desc': 'Index and middle fingers crossed',
    'fact': 'R = crossed fingers for luck!'
  },
  {
    'letter': 'S',
    'hand': '✊',
    'desc': 'Fist with thumb over fingers',
    'fact': 'S is a tight fist!'
  },
  {
    'letter': 'T',
    'hand': '✊',
    'desc': 'Thumb between index and middle finger',
    'fact': 'T = thumb tucked inside!'
  },
  {
    'letter': 'U',
    'hand': '✌️',
    'desc': 'Index and middle together pointing up',
    'fact': 'U = two fingers united!'
  },
  {
    'letter': 'V',
    'hand': '✌️',
    'desc': 'Index and middle spread in a V',
    'fact': 'V = Victory sign!'
  },
  {
    'letter': 'W',
    'hand': '🖖',
    'desc': 'Three fingers spread (index, middle, ring)',
    'fact': 'W = three points like the letter!'
  },
  {
    'letter': 'X',
    'hand': '☝️',
    'desc': 'Index finger hooked or bent',
    'fact': 'X = hooked come-here finger!'
  },
  {
    'letter': 'Y',
    'hand': '🤙',
    'desc': 'Thumb and pinky out, others closed',
    'fact': 'Y = hang loose / shaka!'
  },
  {
    'letter': 'Z',
    'hand': '☝️',
    'desc': 'Index draws a Z shape in the air',
    'fact': 'Z is drawn just like you write it!'
  },
];

const List<Map<String, String>> kASLAlphabet = [
  {
    'letter': 'A',
    'hand': '✊',
    'desc': 'Fist with thumb resting on side',
    'fact': 'One of the most universal letters!'
  },
  {
    'letter': 'B',
    'hand': '🖐️',
    'desc': 'Fingers straight up, thumb folded across',
    'fact': 'Looks like holding up a flat B!'
  },
  {
    'letter': 'C',
    'hand': '🤏',
    'desc': 'Hand curved open like letter C',
    'fact': 'C-shape is the same worldwide!'
  },
  {
    'letter': 'D',
    'hand': '👆',
    'desc': 'Index up, middle+ring+pinky touch thumb',
    'fact': 'Forms a D loop!'
  },
  {
    'letter': 'E',
    'hand': '🤞',
    'desc': 'All fingers bent, thumb tucked',
    'fact': 'E = compressed fingers!'
  },
  {
    'letter': 'F',
    'hand': '👌',
    'desc': 'Index+thumb touch, other 3 fingers up',
    'fact': 'F is OK with three fingers up!'
  },
  {
    'letter': 'G',
    'hand': '👉',
    'desc': 'Index and thumb point to the side',
    'fact': 'G points like a gun!'
  },
  {
    'letter': 'H',
    'hand': '✌️',
    'desc': 'Index+middle together pointing sideways',
    'fact': 'H is two fingers lying flat!'
  },
  {
    'letter': 'I',
    'hand': '🤙',
    'desc': 'Pinky up, other fingers closed',
    'fact': 'I = single pinky standing tall!'
  },
  {
    'letter': 'J',
    'hand': '🤙',
    'desc': 'Pinky traces a J in the air',
    'fact': 'J moves — it\'s drawn in air!'
  },
  {
    'letter': 'K',
    'hand': '✌️',
    'desc': 'Index up, middle angled, thumb between',
    'fact': 'K has the most unique shape!'
  },
  {
    'letter': 'L',
    'hand': '🤙',
    'desc': 'Thumb out + index up = L shape',
    'fact': 'L looks exactly like the letter!'
  },
  {
    'letter': 'M',
    'hand': '✊',
    'desc': 'Three fingers fold over tucked thumb',
    'fact': 'M = three mountains!'
  },
  {
    'letter': 'N',
    'hand': '✊',
    'desc': 'Two fingers fold over tucked thumb',
    'fact': 'N = two mountains!'
  },
  {
    'letter': 'O',
    'hand': '👌',
    'desc': 'All fingers curve to touch thumb',
    'fact': 'O = perfect round shape!'
  },
  {
    'letter': 'P',
    'hand': '👇',
    'desc': 'K handshape rotated downward',
    'fact': 'P = K facing the ground!'
  },
  {
    'letter': 'Q',
    'hand': '👇',
    'desc': 'G shape pointing downward',
    'fact': 'Q = G upside down!'
  },
  {
    'letter': 'R',
    'hand': '🤞',
    'desc': 'Index and middle crossed over each other',
    'fact': 'R = fingers crossed!'
  },
  {
    'letter': 'S',
    'hand': '✊',
    'desc': 'Closed fist, thumb over fingers',
    'fact': 'S = solid fist!'
  },
  {
    'letter': 'T',
    'hand': '✊',
    'desc': 'Thumb inserted between index and middle',
    'fact': 'T = thumb popping through!'
  },
  {
    'letter': 'U',
    'hand': '✌️',
    'desc': 'Index+middle together pointing up',
    'fact': 'U = united fingers!'
  },
  {
    'letter': 'V',
    'hand': '✌️',
    'desc': 'Index+middle spread apart upward',
    'fact': 'V = victory / peace!'
  },
  {
    'letter': 'W',
    'hand': '🖖',
    'desc': 'Three fingers spread upward',
    'fact': 'W = three prongs!'
  },
  {
    'letter': 'X',
    'hand': '☝️',
    'desc': 'Index finger bent like a hook',
    'fact': 'X = crooked finger!'
  },
  {
    'letter': 'Y',
    'hand': '🤙',
    'desc': 'Thumb + pinky extended outward',
    'fact': 'Y = the shaka sign!'
  },
  {
    'letter': 'Z',
    'hand': '☝️',
    'desc': 'Index traces a Z shape in air',
    'fact': 'Z = written in the air!'
  },
];

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
      'color': const Color(0xFFFFC107)
    },
    {'label': 'ISL', 'icon': Icons.language, 'color': const Color(0xFFFF6D00)},
    {
      'label': 'ASL',
      'icon': Icons.sign_language,
      'color': const Color(0xFF00BCD4)
    },
    {
      'label': 'Situations',
      'icon': Icons.place,
      'color': const Color(0xFF7C4DFF)
    },
    {'label': 'Alphabets', 'icon': Icons.abc, 'color': const Color(0xFF9C27B0)},
  ];

  final List<String> _kidsSubCategories = [
    'Animals',
    'Colors',
    'Family',
    'Feelings'
  ];

  final Map<String, List<Map<String, dynamic>>> _kidsData = {
    'Animals': [
      {
        'name': 'CAT',
        'emoji': '🐱',
        'videoKey': 'CAT',
        'how': 'Curl fingers like whiskers near cheeks',
        'fact': 'One of the most recognized animal signs!',
        'steps': [
          'Make a C shape near your cheek',
          'Pull outward like cat whiskers'
        ]
      },
      {
        'name': 'DEAR',
        'emoji': '🦌',
        'videoKey': 'DEAR',
        'how': 'Pat thigh twice then snap fingers',
        'fact': 'A very expressive animal sign!',
        'steps': ['Pat your thigh twice', 'Then snap your fingers']
      },
      {
        'name': 'HORSE',
        'emoji': '🐎',
        'videoKey': 'HORSE',
        'how': 'Two fingers on thumb hop forward like hooves',
        'fact': 'Galloping fingers = galloping horse!',
        'steps': [
          'Place two fingers on thumb side',
          'Hop forward like galloping'
        ]
      },
      {
        'name': 'OX',
        'emoji': '🐂',
        'videoKey': 'OX',
        'how': 'Horns gesture from temples outward',
        'fact': 'Strong and bold like the animal!',
        'steps': [
          'Place index fingers at temples',
          'Curve outward like ox horns'
        ]
      },
      {
        'name': 'PENGUIN',
        'emoji': '🐧',
        'videoKey': 'PENGUIN',
        'how': 'Waddle hands at sides while moving',
        'fact': 'Waddling is the key movement!',
        'steps': [
          'Hold hands flat at sides',
          'Sway side to side like a penguin'
        ]
      },
      {
        'name': 'PANDA',
        'emoji': '🐼',
        'videoKey': 'PANDA',
        'how': 'Draw circles around eyes like panda patches',
        'fact': 'The eye patches make this sign unique!',
        'steps': [
          'Form O shapes with both hands',
          'Place around eyes like panda patches'
        ]
      },
      {
        'name': 'RAINO',
        'emoji': '🦏',
        'videoKey': 'RAINO',
        'how': 'Index finger on nose tip pointing forward like horn',
        'fact': 'The horn is the defining feature!',
        'steps': [
          'Point index finger at nose tip',
          'Tilt forward to show the horn'
        ]
      },
      {
        'name': 'COW',
        'emoji': '🐄',
        'videoKey': 'COW',
        'how': 'Y handshape twisted at temple like horns',
        'fact': 'The Y shape represents cow horns!',
        'steps': [
          'Make Y handshape with pinky and thumb',
          'Twist at your temple to show horns'
        ]
      },
      {
        'name': 'BIRD',
        'emoji': '🐦',
        'videoKey': 'BIRD',
        'how': 'Open and close index + thumb near mouth like a beak',
        'fact': 'Looks just like a bird beak opening!',
        'steps': [
          'Bring index finger and thumb to mouth',
          'Open and close them like a beak'
        ]
      },
      {
        'name': 'ELEPHANT',
        'emoji': '🐘',
        'videoKey': 'ELEPHANT',
        'how': 'Swing arm from nose downward like a trunk',
        'fact': 'The sweeping arm mimics the trunk!',
        'steps': [
          'Start hand at nose',
          'Swing arm downward and forward like trunk'
        ]
      },
    ],
    'Colors': [
      {
        'name': 'RED',
        'emoji': '🔴',
        'videoKey': 'RED',
        'how': 'Point index finger to lips and move down',
        'fact': 'Red lips inspired this sign!',
        'steps': ['Point index finger to your lips', 'Brush downward slightly']
      },
      {
        'name': 'BLUE',
        'emoji': '🔵',
        'videoKey': 'BLUE',
        'how': 'Shake B hand at shoulder level',
        'fact': 'Letter B shaking = Blue!',
        'steps': [
          'Form letter B with fingers',
          'Shake hand side to side at shoulder'
        ]
      },
      {
        'name': 'GREEN',
        'emoji': '🟢',
        'videoKey': 'GREEN',
        'how': 'Shake G hand at shoulder level',
        'fact': 'Letter G shaking = Green!',
        'steps': [
          'Form letter G with thumb and index',
          'Shake hand side to side'
        ]
      },
      {
        'name': 'YELLOW',
        'emoji': '🟡',
        'videoKey': 'YELLOW',
        'how': 'Shake Y hand at shoulder level',
        'fact': 'Letter Y shaking = Yellow!',
        'steps': [
          'Form Y shape with pinky and thumb',
          'Shake at shoulder level'
        ]
      },
      {
        'name': 'WHITE',
        'emoji': '⬜',
        'videoKey': 'WHITE',
        'how': 'Open hand on chest pull outward closing fingers',
        'fact': 'Like pulling something white from your heart!',
        'steps': [
          'Place open hand flat on chest',
          'Pull outward while closing fingers'
        ]
      },
      {
        'name': 'BLACK',
        'emoji': '⬛',
        'videoKey': 'BLACK',
        'how': 'Index finger brushes across forehead left to right',
        'fact': 'Drawing a line across the brow!',
        'steps': [
          'Extend index finger',
          'Brush across forehead from left to right'
        ]
      },
      {
        'name': 'ORANGE',
        'emoji': '🟠',
        'videoKey': 'ORANGE',
        'how': 'Squeeze fist near chin like squeezing an orange',
        'fact': 'Mimics squeezing orange juice!',
        'steps': ['Make a fist near chin', 'Open and close hand repeatedly']
      },
      {
        'name': 'PINK',
        'emoji': '🌸',
        'videoKey': 'PINK',
        'how': 'P handshape brushed down on lips',
        'fact': 'Pink is shown near the lips just like red!',
        'steps': [
          'Form P with index and middle finger',
          'Brush downward on lips'
        ]
      },
    ],
    'Family': [
      {
        'name': 'MOM',
        'emoji': '👩',
        'videoKey': 'MOM',
        'how': 'Touch chin with open hand fingers spread',
        'fact': 'Female signs are made near the chin!',
        'steps': ['Spread all five fingers open', 'Tap thumb to chin twice']
      },
      {
        'name': 'DAD',
        'emoji': '👨',
        'videoKey': 'DAD',
        'how': 'Touch forehead with open hand fingers spread',
        'fact': 'Male signs are made near the forehead!',
        'steps': ['Spread all five fingers open', 'Tap thumb to forehead twice']
      },
      {
        'name': 'SISTER',
        'emoji': '👧',
        'videoKey': 'SISTER',
        'how': 'Slide A hand along jaw from ear to chin',
        'fact': 'Combines female location with A handshape!',
        'steps': [
          'Make A handshape at ear level',
          'Slide down along jawline to chin'
        ]
      },
      {
        'name': 'BROTHER',
        'emoji': '👦',
        'videoKey': 'BROTHER',
        'how': 'Slide A hand along forehead from ear to center',
        'fact': 'Male version of sister sign!',
        'steps': [
          'Make A handshape at ear level',
          'Slide across forehead to center'
        ]
      },
      {
        'name': 'FRIEND',
        'emoji': '🤝',
        'videoKey': 'FRIEND',
        'how': 'Hook index fingers together and swap positions',
        'fact': 'Interlocking fingers = connected friends!',
        'steps': ['Hook index fingers together', 'Flip hands and hook again']
      },
      {
        'name': 'BABY',
        'emoji': '👶',
        'videoKey': 'BABY',
        'how': 'Rock arms like cradling a baby',
        'fact': 'Universal rocking motion for a baby!',
        'steps': [
          'Cross arms in front of body',
          'Rock them gently side to side'
        ]
      },
      {
        'name': 'GRANDMA',
        'emoji': '👵',
        'videoKey': 'GRANDMA',
        'how': 'Open 5 hand at chin move forward in two arcs',
        'fact': 'Two arcs show the generation gap!',
        'steps': [
          'Open hand at chin with thumb touching',
          'Move forward in two bouncing arcs'
        ]
      },
      {
        'name': 'GRANDPA',
        'emoji': '👴',
        'videoKey': 'GRANDPA',
        'how': 'Open 5 hand at forehead move forward in two arcs',
        'fact': 'Same as grandma but from forehead!',
        'steps': [
          'Open hand at forehead with thumb touching',
          'Move forward in two bouncing arcs'
        ]
      },
    ],
    'Feelings': [
      {
        'name': 'HAPPY',
        'emoji': '😊',
        'videoKey': 'HAPPY',
        'how': 'Brush open hand upward on chest twice',
        'fact': 'Lifting motion shows positive feeling!',
        'steps': ['Place flat hand on chest', 'Brush upward twice quickly']
      },
      {
        'name': 'SAD',
        'emoji': '😢',
        'videoKey': 'SAD',
        'how': 'Pull both hands slowly down face',
        'fact': 'Hands trace the path of tears!',
        'steps': [
          'Hold both open hands in front of face',
          'Slowly pull them downward'
        ]
      },
      {
        'name': 'ANGRY',
        'emoji': '😠',
        'videoKey': 'ANGRY',
        'how': 'Claw both hands near face, scrunch face',
        'fact': 'Tension in hands shows anger!',
        'steps': [
          'Claw both hands with bent fingers',
          'Hold near face with tense expression'
        ]
      },
      {
        'name': 'BOARD',
        'emoji': '😑',
        'videoKey': 'BOARD',
        'how': 'Flat expression with open hands dropping',
        'fact': 'Bored = energy dropping away!',
        'steps': [
          'Hold open hands up near face',
          'Let them drop slowly downward'
        ]
      },
      {
        'name': 'BUZY',
        'emoji': '😰',
        'videoKey': 'BUZY',
        'how': 'Both hands move rapidly in alternating circles',
        'fact': 'Busy hands = busy person!',
        'steps': [
          'Hold both fists up',
          'Rotate them rapidly in alternate circles'
        ]
      },
      {
        'name': 'TIRED',
        'emoji': '😴',
        'videoKey': 'TIRED',
        'how': 'Bent hands drop down from chest showing exhaustion',
        'fact': 'The drooping shows energy draining away!',
        'steps': [
          'Hold bent open hands on chest',
          'Let them drop downward with slumped shoulders'
        ]
      },
      {
        'name': 'EXCITED',
        'emoji': '🤩',
        'videoKey': 'EXCITED',
        'how': 'Alternating middle fingers brush up on chest',
        'fact': 'The alternating motion shows bubbling excitement!',
        'steps': [
          'Extend middle fingers of both hands',
          'Alternate brushing them up on chest'
        ]
      },
    ],
  };

  final List<Map<String, dynamic>> _islData = [
    {
      'name': 'NAMASTE',
      'emoji': '🙏',
      'videoKey': 'NAMASTE',
      'how': 'Press palms together in prayer position',
      'difficulty': 'Easy',
      'fact': 'The most universal Indian greeting!',
      'steps': [
        'Bring both palms together',
        'Hold at chest level and bow slightly'
      ]
    },
    {
      'name': 'BYE',
      'emoji': '👋',
      'videoKey': 'BYE',
      'how': 'Wave hand outward gently',
      'difficulty': 'Easy',
      'fact': 'Simple goodbye wave!',
      'steps': ['Raise open hand', 'Wave it outward as a farewell']
    },
    {
      'name': 'AGAIN',
      'emoji': '🔁',
      'videoKey': 'AGAIN',
      'how': 'Arc hand from palm back down into palm',
      'difficulty': 'Easy',
      'fact': 'Circular motion = repeat!',
      'steps': ['Hold one palm flat', 'Arc other hand into it from below']
    },
    {
      'name': 'HE',
      'emoji': '👨',
      'videoKey': 'HE',
      'how': 'Point forward with index finger',
      'difficulty': 'Easy',
      'fact': 'Direct pointing sign!',
      'steps': ['Extend index finger', 'Point forward to indicate he/him']
    },
    {
      'name': 'HELLO',
      'emoji': '👋',
      'videoKey': 'HELLO',
      'how': 'Open hand wave from forehead outward',
      'difficulty': 'Medium',
      'fact': 'Circle represents togetherness!',
      'steps': ['Raise open hand to forehead', 'Wave it outward']
    },
    {
      'name': 'INDIAN',
      'emoji': '🇮🇳',
      'videoKey': 'INDIAN',
      'how': 'R handshape brush down across palm',
      'difficulty': 'Easy',
      'fact': 'Unique to Indian Sign Language!',
      'steps': [
        'Make R handshape with crossed fingers',
        'Brush downward across your open palm'
      ]
    },
    {
      'name': 'ME',
      'emoji': '👤',
      'videoKey': 'ME',
      'how': 'Point index finger to yourself',
      'difficulty': 'Easy',
      'fact': 'Self-referencing sign!',
      'steps': ['Extend index finger', 'Point it toward your own chest']
    },
    {
      'name': 'PLEASE',
      'emoji': '🙏',
      'videoKey': 'PLEASE',
      'how': 'Flat hand circles clockwise on chest',
      'difficulty': 'Medium',
      'fact': 'Heart area = sincere request!',
      'steps': ['Place flat hand on chest', 'Move in clockwise circles']
    },
    {
      'name': 'SHE',
      'emoji': '👩',
      'videoKey': 'SHE',
      'how': 'Point to the side, palm facing down',
      'difficulty': 'Easy',
      'fact': 'Simple pronoun pointing!',
      'steps': ['Extend index finger to the side', 'Keep palm facing downward']
    },
    {
      'name': 'SORRY',
      'emoji': '😔',
      'videoKey': 'SORRY',
      'how': 'A handshape circles on chest',
      'difficulty': 'Easy',
      'fact': 'Fist over heart = sincere apology!',
      'steps': [
        'Make A handshape with closed fist',
        'Circle fist on your chest'
      ]
    },
    {
      'name': 'THANKYOU',
      'emoji': '🫶',
      'videoKey': 'THANKYOU',
      'how': 'Flat hand from chin moves forward and down',
      'difficulty': 'Easy',
      'fact': 'Blowing a kiss of gratitude!',
      'steps': [
        'Touch flat hand to chin',
        'Move hand forward and slightly downward'
      ]
    },
    {
      'name': 'WELCOME',
      'emoji': '🏠',
      'videoKey': 'WELCOME',
      'how': 'Open arm sweeps inward warmly',
      'difficulty': 'Easy',
      'fact': 'Open arms = welcoming gesture!',
      'steps': [
        'Extend one arm outward open',
        'Sweep it inward toward your body warmly'
      ]
    },
  ];

  final List<Map<String, dynamic>> _aslData = [
    {
      'name': 'HELLO',
      'emoji': '👋',
      'videoKey': 'ASL_HELLO',
      'how': 'Open hand wave from forehead outward',
      'difficulty': 'Easy',
      'fact': 'Like saluting with a wave!',
      'steps': [
        'Raise open hand to forehead',
        'Wave it outward away from forehead'
      ]
    },
    {
      'name': 'FORGET',
      'emoji': '🤔',
      'videoKey': 'FORGET',
      'how': 'Flat hand from forehead wipes outward',
      'difficulty': 'Easy',
      'fact': 'Wiping memory from your mind!',
      'steps': ['Touch flat hand to your forehead', 'Move hand outward quickly']
    },
    {
      'name': 'EXCITED',
      'emoji': '🤩',
      'videoKey': 'ASL_EXCITED',
      'how': 'Alternating middle fingers brush up on chest',
      'difficulty': 'Easy',
      'fact': 'Bubbling energy in your chest!',
      'steps': ['Place flat open hand on chest', 'Move in circular pattern']
    },
    {
      'name': 'WRONG',
      'emoji': '❌',
      'videoKey': 'WRONG',
      'how': 'Y handshape tapped to chin',
      'difficulty': 'Easy',
      'fact': 'Y shape tap = wrong!',
      'steps': ['Make Y handshape', 'Tap to chin once']
    },
    {
      'name': 'NEED',
      'emoji': '✅',
      'videoKey': 'NEED',
      'how': 'X handshape bends down repeatedly',
      'difficulty': 'Easy',
      'fact': 'Hooking motion = need/must!',
      'steps': [
        'Make X handshape (hooked index)',
        'Bend wrist down once or twice'
      ]
    },
    {
      'name': 'NO',
      'emoji': '🚫',
      'videoKey': 'NO',
      'how': 'Index and middle finger close onto thumb',
      'difficulty': 'Easy',
      'fact': 'Like a talking mouth saying NO!',
      'steps': [
        'Extend index and middle fingers with thumb out',
        'Snap them down onto thumb'
      ]
    },
    {
      'name': 'WHAT',
      'emoji': '❓',
      'videoKey': 'WHAT',
      'how': 'Index finger waggles side to side',
      'difficulty': 'Easy',
      'fact': 'Questioning waggle!',
      'steps': [
        'Extend index finger',
        'Waggle it side to side with questioning look'
      ]
    },
    {
      'name': 'WORK',
      'emoji': '💼',
      'videoKey': 'WORK',
      'how': 'Chop edge of hand onto other palm',
      'difficulty': 'Easy',
      'fact': 'Sharp chop = work!',
      'steps': [
        'Hold non-dominant hand flat palm up',
        'Chop dominant hand edge onto it firmly'
      ]
    },
    {
      'name': 'COME',
      'emoji': '👉',
      'videoKey': 'COME',
      'how': 'Index finger curls toward yourself',
      'difficulty': 'Easy',
      'fact': 'Beckoning gesture!',
      'steps': ['Extend index finger outward', 'Curl it toward your body']
    },
    {
      'name': 'INTRODUCE',
      'emoji': '🤝',
      'videoKey': 'INTRODUCE',
      'how': 'Both flat hands sweep toward each other',
      'difficulty': 'Easy',
      'fact': 'Bringing two people together!',
      'steps': ['Hold both flat hands apart', 'Sweep them toward each other']
    },
    {
      'name': 'NOTHING',
      'emoji': '🚫',
      'videoKey': 'NOTHING',
      'how': 'O hand shakes outward from chin',
      'difficulty': 'Easy',
      'fact': 'Empty O = nothing!',
      'steps': ['Make O handshape at chin', 'Shake outward to show nothing']
    },
    {
      'name': 'HARD OF EARING',
      'emoji': '👂',
      'videoKey': 'HARD OF EARING',
      'how': 'H handshape bounces near ear',
      'difficulty': 'Easy',
      'fact': 'H = hearing, near ear!',
      'steps': ['Form H handshape near ear', 'Bounce it slightly twice']
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
          'fact': 'Used to tell doctors where it hurts!'
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!'
        },
        {
          'name': 'DOCTOR',
          'how': 'Tap wrist with two fingers like pulse check',
          'fact': 'Mimics checking a patients pulse!'
        },
        {
          'name': 'HELP',
          'how': 'Thumb up fist on flat palm lift both up',
          'fact': 'Most important emergency sign!'
        },
        {
          'name': 'MEDICINE',
          'how': 'Middle finger circles on opposite palm',
          'fact': 'Represents mixing medicine!'
        },
        {
          'name': 'TOILET',
          'how': 'Shake T handshape side to side',
          'fact': 'T = Toilet shaking = movement!'
        },
        {
          'name': 'NURSE',
          'how': 'Tap N handshape on wrist twice',
          'fact': 'Similar to doctor but with N!'
        },
        {
          'name': 'BED',
          'how': 'Tilt head onto praying hands',
          'fact': 'Mimics sleeping on a pillow!'
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
          'fact': 'Universal greeting sign!'
        },
        {
          'name': 'SORRY',
          'how': 'A handshape circles on chest',
          'fact': 'Fist over heart = sincere apology!'
        },
        {
          'name': 'PLEASE',
          'how': 'Flat hand circles clockwise on chest',
          'fact': 'Heart area = sincere request!'
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward',
          'fact': 'Blowing a kiss of gratitude!'
        },
        {
          'name': 'YES',
          'how': 'A handshape nods up and down',
          'fact': 'Like a nodding head!'
        },
        {
          'name': 'NO',
          'how': 'Index and middle finger close onto thumb',
          'fact': 'Like a talking mouth!'
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
          'fact': 'Hand goes to mouth like eating!'
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!'
        },
        {
          'name': 'SLEEP',
          'how': 'Pull open hand down over face closing eyes',
          'fact': 'Hand closing = eyes closing!'
        },
        {
          'name': 'LOVE',
          'how': 'Cross both arms over chest like a hug',
          'fact': 'Universal gesture for love!'
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things together!'
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
          'fact': 'Most important emergency sign!'
        },
        {
          'name': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
          'fact': 'Sharp motion = sharp stop!'
        },
        {
          'name': 'POLICE',
          'how': 'C handshape tapped to badge area on chest',
          'fact': 'C = Cop badge location!'
        },
        {
          'name': 'FIRE',
          'how': 'Wiggle all fingers pointing upward',
          'fact': 'Fingers look like rising flames!'
        },
        {
          'name': 'DANGER',
          'how': 'A handshape sweeps up from under other hand',
          'fact': 'Rising motion = rising danger!'
        },
        {
          'name': 'SOS',
          'how': 'Tap 3 dots 3 dashes 3 dots on your palm',
          'fact': 'Morse code SOS in sign language!'
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
          'fact': 'Like counting bills!'
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things!'
        },
        {
          'name': 'GOOD',
          'how': 'Flat hand from chin moves to other palm',
          'fact': 'Presenting goodness forward!'
        },
        {
          'name': 'STOP',
          'how': 'Chop edge of flat hand onto other palm',
          'fact': 'Sharp chop = sharp stop!'
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
          'fact': 'Blowing a kiss of gratitude!'
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
          'fact': 'Hand goes to mouth like eating!'
        },
        {
          'name': 'WATER',
          'how': 'W handshape tapped to chin twice',
          'fact': 'W stands for Water!'
        },
        {
          'name': 'MORE',
          'how': 'Bring flat O hands together tapping fingertips',
          'fact': 'Gathering more things!'
        },
        {
          'name': 'GOOD',
          'how': 'Flat hand from chin moves to other palm',
          'fact': 'Presenting goodness forward!'
        },
        {
          'name': 'THANK YOU',
          'how': 'Flat hand from chin moves forward and down',
          'fact': 'Blowing a kiss of gratitude!'
        },
      ],
    },
  ];

  int _alphabetTab = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
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

  void _openSituationDetail(Map<String, dynamic> situation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    borderRadius: BorderRadius.circular(2))),
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
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(situation['icon'] as IconData,
                        color: situation['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(situation['name'],
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('${situation['count']} signs to learn',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: const Color(0xFFB0BEC5))),
                      ]),
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
                              : const Color(0xFF2A2A2A)),
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
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                  isLearned
                                      ? Icons.check_circle
                                      : Icons.sign_language,
                                  color: isLearned
                                      ? const Color(0xFF69F0AE)
                                      : color,
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(sign['name'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text(sign['how'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: const Color(0xFFB0BEC5))),
                                ])),
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                for (int k = 0; k < 3; k++) {
                                  await _tts.speak(sign['name']);
                                  await Future.delayed(
                                      const Duration(milliseconds: 1200));
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF7C4DFF)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFF7C4DFF)
                                            .withOpacity(0.3))),
                                child: Column(children: [
                                  const Icon(Icons.volume_up,
                                      color: Color(0xFF7C4DFF), size: 18),
                                  Text('×3',
                                      style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: const Color(0xFF7C4DFF),
                                          fontWeight: FontWeight.bold)),
                                ]),
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
    String? videoPath;
    final videoKey = sign['videoKey'] as String?;
    if (videoKey != null) videoPath = kSignVideoAssets[videoKey];
    if (videoPath == null) {
      final signName = (sign['name'] as String?)?.trim().toUpperCase();
      if (signName != null) videoPath = kSignVideoAssets[signName];
    }
    final enrichedSign = Map<String, dynamic>.from(sign);
    if (videoPath != null) enrichedSign['video'] = videoPath;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _SignAnimationSheet(
          sign: enrichedSign,
          color: color,
          tts: _tts,
          onMarkLearned: () => _markLearned(sign['name']),
          isLearned: _learnedSigns.contains(sign['name']),
        ),
      ),
    );
  }

  void _showAlphabetDetail(Map<String, String> alpha, Color color) {
    final learnKey = 'ALPHA_${alpha['letter']}';
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isLearned = _learnedSigns.contains(learnKey);
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, sc) => SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: color.withOpacity(0.3))),
                      child: Column(children: [
                        Text(alpha['hand']!,
                            style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 12),
                        Text(alpha['letter']!,
                            style: GoogleFonts.poppins(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: color)),
                        const SizedBox(height: 6),
                        Text(_alphabetTab == 0 ? 'ISL' : 'ASL',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: color.withOpacity(0.7),
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How to sign:',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Text('🤲', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(alpha['desc']!,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.4))),
                            ]),
                          ]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFD740).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFFD740).withOpacity(0.2))),
                      child: Row(children: [
                        const Text('💡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(alpha['fact']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFFFD740),
                                    fontStyle: FontStyle.italic))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _tts.speak(alpha['letter']!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xFF7C4DFF).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF7C4DFF)
                                        .withOpacity(0.4))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.volume_up,
                                      color: Color(0xFF7C4DFF), size: 20),
                                  const SizedBox(width: 6),
                                  Text('Pronounce',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFF7C4DFF),
                                          fontWeight: FontWeight.w600)),
                                ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (!isLearned) {
                            _markLearned(learnKey);
                            setModalState(() {});
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: isLearned
                                ? const Color(0xFF69F0AE).withOpacity(0.15)
                                : color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isLearned
                                    ? const Color(0xFF69F0AE).withOpacity(0.4)
                                    : color.withOpacity(0.4)),
                          ),
                          child: Icon(
                              isLearned
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color:
                                  isLearned ? const Color(0xFF69F0AE) : color,
                              size: 22),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          );
        },
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
              if (context.canPop())
                context.pop();
              else
                context.go('/home');
            },
          ),
          title: Text('Learn & Sense',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          actions: [
            IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {})
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
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
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.amber)),
                const SizedBox(width: 16),
                const Icon(Icons.check_circle_outline,
                    color: Color(0xFF69F0AE), size: 16),
                const SizedBox(width: 4),
                Text('${_learnedSigns.length} Learned',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: const Color(0xFF69F0AE))),
              ]),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildCategoryScroll(),
            Expanded(
                child: FadeTransition(
                    opacity: _fadeAnimation, child: _buildContent())),
          ],
        ),
      ),
    );
  }

  // ── FIXED: Spacious category scroll ──────────────────
  Widget _buildCategoryScroll() {
    return Container(
      height: 110,
      color: const Color(0xFF0A0A0A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (cat['color'] as Color).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      border: Border.all(
                          color: isSelected
                              ? cat['color'] as Color
                              : const Color(0xFF2A2A2A),
                          width: isSelected ? 2.5 : 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color:
                                      (cat['color'] as Color).withOpacity(0.3),
                                  blurRadius: 14,
                                  spreadRadius: 2)
                            ]
                          : [],
                    ),
                    child: Icon(cat['icon'] as IconData,
                        color: isSelected
                            ? cat['color'] as Color
                            : const Color(0xFF6B6B6B),
                        size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(cat['label'],
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isSelected
                              ? cat['color'] as Color
                              : const Color(0xFF6B6B6B),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal)),
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
        return _buildAlphabetsSection();
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
          border: Border.all(color: const Color(0xFF2A2A2A))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("You've learned ${_learnedSigns.length} signs today!",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
          Text('$_xp XP',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: (_xp % 200) / 200,
            backgroundColor: const Color(0xFF2A2A2A),
            color: const Color(0xFF00BCD4),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_xp % 200}/200 XP to next level',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: const Color(0xFFB0BEC5))),
          Row(children: [
            const Icon(Icons.local_fire_department,
                color: Colors.orange, size: 14),
            const SizedBox(width: 4),
            Text('$_streak day streak',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange)),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: color)),
    );
  }

  Widget _buildSignGrid(
      {required List<Map<String, dynamic>> signs,
      required Color color,
      String? badgeKey,
      Color? badgeColor}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12),
      itemCount: signs.length,
      itemBuilder: (context, i) {
        final sign = signs[i];
        final isLearned = _learnedSigns.contains(sign['name']);
        final videoKey = sign['videoKey'] as String?;
        final hasVideo = videoKey != null && kSignVideoAssets[videoKey] != null;
        return GestureDetector(
          onTap: () => _showSignAnimation(sign, color),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isLearned
                      ? color.withOpacity(0.6)
                      : color.withOpacity(0.2)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(children: [
                  Container(
                      height: 110,
                      width: double.infinity,
                      color: color.withOpacity(0.1),
                      child: Center(
                          child: Text(sign['emoji'] ?? '✋',
                              style: const TextStyle(fontSize: 56)))),
                  if (hasVideo)
                    Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.play_circle_filled,
                                color: color, size: 12),
                            const SizedBox(width: 3),
                            Text('Video',
                                style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        )),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sign['name'],
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(sign['how'],
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: const Color(0xFFB0BEC5)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
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
                                            fontSize: 9, color: color))),
                            isLearned
                                ? Icon(Icons.check_circle,
                                    color: color, size: 16)
                                : Icon(Icons.play_circle_outline,
                                    color: color, size: 16),
                          ]),
                    ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── FIXED: Spacious Kids section with better subcategory pills ──
  Widget _buildKidsSection() {
    final subCat = _kidsSubCategories[_selectedSubCategory];
    final signs = _kidsData[subCat] ?? [];
    const color = Color(0xFFFFC107);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Learn Signs for Kids',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text('Tap any card to watch the sign video',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFB0BEC5))),
        const SizedBox(height: 18),
        // ── Subcategory pills ──
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _kidsSubCategories.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedSubCategory == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedSubCategory = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: isSelected ? color : const Color(0xFF2A2A2A)),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: color.withOpacity(0.25),
                                blurRadius: 8,
                                spreadRadius: 1)
                          ]
                        : [],
                  ),
                  child: Text(_kidsSubCategories[i],
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFFB0BEC5),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildSignGrid(signs: signs, color: color),
        _buildProgressWidget(),
      ]),
    );
  }

  Widget _buildISLSection() {
    const color = Color(0xFFFF6D00);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Indian Sign Language',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Container(
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Expanded(child: Container(color: const Color(0xFFFF6D00))),
              Expanded(child: Container(color: Colors.white)),
              Expanded(child: Container(color: const Color(0xFF388E3C))),
            ])),
        Text('Tap any card to watch the sign video',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFB0BEC5))),
        const SizedBox(height: 16),
        _buildSignGrid(
            signs: _islData,
            color: color,
            badgeKey: 'difficulty',
            badgeColor: const Color(0xFF69F0AE)),
        _buildProgressWidget(),
      ]),
    );
  }

  Widget _buildASLSection() {
    const color = Color(0xFF00BCD4);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('American Sign Language',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text('Tap any card to watch the sign video',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFB0BEC5))),
        const SizedBox(height: 16),
        _buildSignGrid(
            signs: _aslData,
            color: color,
            badgeKey: 'difficulty',
            badgeColor: const Color(0xFF69F0AE)),
        _buildProgressWidget(),
      ]),
    );
  }

  Widget _buildSituationsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              mainAxisSpacing: 10),
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
                        color: (sit['color'] as Color).withOpacity(0.3))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: (sit['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(sit['icon'] as IconData,
                              color: sit['color'] as Color, size: 20)),
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
                          borderRadius: BorderRadius.circular(2)),
                      const SizedBox(height: 4),
                      Text('$learnedCount/$total learned',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: const Color(0xFF6B6B6B))),
                    ]),
              ),
            );
          },
        ),
        _buildProgressWidget(),
      ]),
    );
  }

  Widget _buildAlphabetsSection() {
    const islColor = Color(0xFFFF6D00);
    const aslColor = Color(0xFF00BCD4);
    const color = Color(0xFF9C27B0);
    final currentAlphabet = _alphabetTab == 0 ? kISLAlphabet : kASLAlphabet;
    final activeColor = _alphabetTab == 0 ? islColor : aslColor;
    final learnedCount = currentAlphabet
        .where((a) => _learnedSigns.contains('ALPHA_${a['letter']}'))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sign Language Alphabets',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text('Learn A–Z hand shapes for ISL and ASL',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFB0BEC5))),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2A2A))),
          child: Row(children: [
            _alphabetTabBtn('ISL', 0, islColor),
            _alphabetTabBtn('ASL', 1, aslColor)
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: activeColor.withOpacity(0.2))),
          child: Row(children: [
            Icon(Icons.abc, color: activeColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('$learnedCount / 26 letters learned',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                      value: learnedCount / 26,
                      backgroundColor: const Color(0xFF2A2A2A),
                      color: activeColor,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(3)),
                ])),
            const SizedBox(width: 10),
            Text('${((learnedCount / 26) * 100).toInt()}%',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: activeColor,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: currentAlphabet.length,
          itemBuilder: (context, i) {
            final alpha = currentAlphabet[i];
            final learnKey = 'ALPHA_${alpha['letter']}';
            final isLearned = _learnedSigns.contains(learnKey);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showAlphabetDetail(alpha, activeColor);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isLearned
                      ? activeColor.withOpacity(0.12)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isLearned
                          ? activeColor.withOpacity(0.6)
                          : activeColor.withOpacity(0.2)),
                  boxShadow: isLearned
                      ? [
                          BoxShadow(
                              color: activeColor.withOpacity(0.15),
                              blurRadius: 8)
                        ]
                      : [],
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(alpha['hand']!,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(alpha['letter']!,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isLearned ? activeColor : Colors.white)),
                      if (isLearned)
                        Icon(Icons.check_circle, color: activeColor, size: 12),
                    ]),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              color.withOpacity(0.12),
              activeColor.withOpacity(0.08)
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              _alphabetTab == 0
                  ? 'ISL uses a one-handed alphabet. Tap any letter to learn its handshape!'
                  : 'ASL also uses a one-handed alphabet. Letters J and Z include movement!',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFFB0BEC5)),
            )),
          ]),
        ),
        _buildProgressWidget(),
      ]),
    );
  }

  Widget _alphabetTabBtn(String label, int index, Color color) {
    final isActive = _alphabetTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _alphabetTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: isActive ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? Colors.white : const Color(0xFF6B6B6B)))),
        ),
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

  const _SignAnimationSheet(
      {required this.sign,
      required this.color,
      required this.tts,
      required this.onMarkLearned,
      required this.isLearned});

  @override
  State<_SignAnimationSheet> createState() => _SignAnimationSheetState();
}

class _SignAnimationSheetState extends State<_SignAnimationSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  VideoPlayerController? _videoController;
  bool _hasVideo = false;
  bool _videoReady = false;
  bool _isPlaying = false;
  bool _learned = false;

  @override
  void initState() {
    super.initState();
    _learned = widget.isLearned;
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _initMedia();
  }

  Future<void> _initMedia() async {
    final videoPath = widget.sign['video'] as String?;
    if (videoPath != null && videoPath.isNotEmpty) {
      _hasVideo = true;
      try {
        _videoController = VideoPlayerController.asset(videoPath);
        await _videoController!.initialize();
        await _videoController!.setLooping(false);
        _videoController!.addListener(_onVideoUpdate);
        if (!mounted) return;
        setState(() => _videoReady = true);
      } catch (_) {
        _hasVideo = false;
      }
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final isPlaying = _videoController?.value.isPlaying ?? false;
    if (_isPlaying != isPlaying) setState(() => _isPlaying = isPlaying);
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playVideo() async {
    if (_videoController == null || !_videoReady) return;
    HapticFeedback.lightImpact();
    await _videoController!.seekTo(Duration.zero);
    await _videoController!.play();
  }

  Future<void> _pauseVideo() async => _videoController?.pause();

  @override
  Widget build(BuildContext context) {
    final steps = widget.sign['steps'] as List? ?? [];
    final emoji = widget.sign['emoji'] ?? '✋';

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.sign['name'],
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(widget.sign['how'] ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFFB0BEC5))),
                  ])),
              if (_hasVideo)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.color.withOpacity(0.4))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.videocam, color: widget.color, size: 14),
                    const SizedBox(width: 4),
                    Text('Video',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: widget.color)),
                  ]),
                ),
            ]),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_hasVideo) {
                  _isPlaying ? _pauseVideo() : _playVideo();
                }
              },
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.color.withOpacity(0.3))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _hasVideo
                      ? (_videoReady && _videoController != null
                          ? Stack(alignment: Alignment.center, children: [
                              SizedBox.expand(
                                  child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                          width: _videoController!
                                              .value.size.width,
                                          height: _videoController!
                                              .value.size.height,
                                          child:
                                              VideoPlayer(_videoController!)))),
                              AnimatedOpacity(
                                opacity: _isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: widget.color.withOpacity(0.85),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                widget.color.withOpacity(0.4),
                                            blurRadius: 16,
                                            spreadRadius: 2)
                                      ]),
                                  child: const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 32),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: VideoProgressIndicator(
                                      _videoController!,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                          playedColor: widget.color,
                                          bufferedColor:
                                              widget.color.withOpacity(0.3),
                                          backgroundColor: Colors.black38))),
                            ])
                          : Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  CircularProgressIndicator(
                                      color: widget.color, strokeWidth: 2),
                                  const SizedBox(height: 12),
                                  Text('Loading video...',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF6B6B6B))),
                                ])))
                      : AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (_, __) => Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: Text(emoji,
                                            style:
                                                const TextStyle(fontSize: 80))),
                                    const SizedBox(height: 12),
                                    Text('No video available',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFF6B6B6B))),
                                  ]))),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (steps.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                              color: widget.color
                                                  .withOpacity(0.15),
                                              shape: BoxShape.circle),
                                          child: Center(
                                              child: Text('${i + 1}',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: widget.color,
                                                      fontWeight:
                                                          FontWeight.bold)))),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(steps[i],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.white))),
                                    ]),
                              )),
                    ]),
              ),
            if (widget.sign['fact'] != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFD740).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFFFD740).withOpacity(0.2))),
                child: Row(children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(widget.sign['fact'],
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFFD740),
                              fontStyle: FontStyle.italic))),
                ]),
              ),
            ],
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_hasVideo) {
                      _isPlaying ? _pauseVideo() : _playVideo();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _hasVideo
                                  ? (_isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow)
                                  : Icons.sign_language,
                              color: Colors.white,
                              size: 20),
                          const SizedBox(width: 6),
                          Text(
                              _hasVideo
                                  ? (_isPlaying ? 'Pause Video' : 'Play Video')
                                  : 'No Video',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ]),
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
                          color: const Color(0xFF7C4DFF).withOpacity(0.4))),
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
                      size: 22),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

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
              fontWeight: FontWeight.bold));
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(item['x'] as double, item['y'] as double));
    }
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) => false;
}
