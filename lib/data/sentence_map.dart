const Map<String, String> sentenceMap = {
  'HELLO'    : 'Hello, nice to meet you!',
  'HELP'     : 'I need help please!',
  'WATER'    : 'I need water please.',
  'FOOD'     : 'I am hungry.',
  'TOILET'   : 'Where is the restroom?',
  'YES'      : 'Yes.',
  'NO'       : 'No.',
  'THANK_YOU': 'Thank you very much!',
  'SORRY'    : 'I am sorry.',
  'PLEASE'   : 'Please.',
  'WHERE'    : 'Where is it?',
  'STOP'     : 'Please stop.',
  'PAIN'     : 'I am in pain.',
  'DOCTOR'   : 'I need a doctor.',
  'CALL'     : 'Please call someone.',
};

String expandSentence(String sign) {
  return sentenceMap[sign.toUpperCase()] ?? sign;
}