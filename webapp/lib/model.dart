// TODO To be replaced with real models. Just dumping dummy data here to keep controller.dart clean

Map<String, List<String>> projectData = {
  'COVID IMAQAL' : ['Team Member 1', 'Team Member 2', 'Team Member 3', 'Team Member 4', 'Team Member 5'],
  'COVID Kenya': ['Team Member 1', 'Team Member 3']
  };

Map<String, String> teamMembers  = {
  'Team Member 1' : 'email1@organization.org',
  'Team Member 2' : 'email2@organization.org',
  'Team Member 3': 'email3@organization.org'
};

Map conversationData = {
    'needs-urgent-intervention': 3,
    'awaiting-reply': 20,
    'conversations': [
      {
        'text': 'Waa inlahelaa daryel cifimad iyo nabad warta nanakashaqeyan bulshada dhaman wanasodhaweyney naa sanad ka nasohayo hadoo allah nakarsiyo',
        'demogs': 'Male, 20, Displaced'
      },
      {
        'text': 'Ok mahad sanidin',
        'demogs': 'Female, 38'
      },
      {
        'text': 'In lahelo dawlad hoose oo xoogan waxna kaqaban karta ilaalinta sharciyada iyo xuquuqaha shaqsiga ah ee bulshada dhexdeeda',
        'demogs': 'Male'
      }
    ]
};

List<String> projectOrganizations;

List<String> get configurationReponseLanguageData => ['English', 'Somali'];

Map<String, TagStyle> tags = {
  'rumour - origin': TagStyle.Normal,
  'rumour - virus description': TagStyle.Normal,
  'rumour - cure': TagStyle.Normal,
  'other tag 1': TagStyle.Normal,
  'other tag 2': TagStyle.Normal,
  'other tag 3': TagStyle.Normal
};

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
  Map<String, TagStyle> availableTags;
  Map<String, TagStyle> hasAllTags;
  Map<String, TagStyle> containsLastInTurnTags;
  Map<String, TagStyle> hasNoneTags;
  List<Map> suggestedReplies;
  Map<String, TagStyle> addsTags;
}

enum TagStyle {
  Normal,
  Important,
}

Configuration changeCommsPackage = new Configuration()
  ..availableTags = tags
  ..hasAllTags = {}
  ..containsLastInTurnTags = {'denial': TagStyle.Normal , 'rumour': TagStyle.Normal}
  ..hasNoneTags = {'escalate': TagStyle.Normal, 'STOP': TagStyle.Normal}
  ..suggestedReplies = messages
  ..addsTags = {'Organic conversation appreciation': TagStyle.Normal, 'Organic conversation hostility': TagStyle.Normal,
    'RP Substance appreciation': TagStyle.Normal, 'RP Substance hostility': TagStyle.Normal};

class User {
  String userName;
  String userEmail;
}
