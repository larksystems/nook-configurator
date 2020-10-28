// TODO To be replaced with real models. Just dumping dummy data here to keep controller.dart clean

List<String> tags = [
  'rumour - origin', 'rumour - virus description', 'rumour - cure', 'other tag 1', 'other tag 2', 'other tag 3'
];

List<Map> messages = [
  {
    "messages":
      [
        "Greetings to you dear listener! Thanks for the beautiful way you are sharing your thoughts with us",
        "Saalan, quruz badan nage guddoon dhagaystaha sharafta leh, waad ku mahadsantahay sida quruxda badana ee aad noola wadageyso fikradahaada",
      ],
    "reviewed": true,
    "reviewed-by": "nancy@whatworks.co.ke",
    "reviewed-date": "2020-10-10"
  },
  {
    "messages":
      [
        "Thanks, we hear you and appreciate. We think it is really important to tell you what we know from trusted sources",
        "Mahadsanid, waan ku maqalnaa waanan kuu mahadnaqaynaa. Waxaa muhiim ah inaan kula wadaagno waxaa aan ognahay oo ka yimid ilo lagu kalsoon yahay",
      ],
    "reviewed": false,
    "reviewed-by": "",
    "reviewed-date": ""
  }
];

class Configuration {
  List<String> hasAllTags;
  List<String> containsLastInTurnTags;
  List<String> hasNoneTags;
  List<Map> suggestedReplies;
  List<String> addsTags;
}

Configuration changeCommsPackage = new Configuration()
  ..hasAllTags = []
  ..containsLastInTurnTags = ['denial', 'rumour']
  ..hasNoneTags = ['escalate', 'STOP']
  ..suggestedReplies = messages
  ..addsTags = ['Organic conversation appreciation', 'Organic conversation hostility', 'RP Substance appreciation', 'RP Substance hostility'];

class User {
  String userName;
  String userEmail;
}
