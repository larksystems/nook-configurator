import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;

import 'controller.dart' as controller;
import 'package:katikati_ui_lib/components/logger.dart';
import 'package:katikati_ui_lib/components/platform/platform.dart' as katikati_platform;
export 'package:katikati_ui_lib/components/platform/platform.dart';
import 'package:katikati_ui_lib/components/platform/platform_constants.dart' as platform_constants;
import 'package:nook/pubsub.dart';
import 'package:nook/model.dart';
import 'package:nook/model_firebase.dart';

Logger log = new Logger('platform.dart');

firestore.Firestore _firestoreInstance;
firestore.Firestore get fireStoreInstance => _firestoreInstance;

DocStorage _docStorage;
PubSubClient _pubsubInstance;
PubSubClient _uptimePubSubInstance;

init() async {
  await katikati_platform.init("assets/firebase_constants.json", (user) {
    String photoURL = katikati_platform.firebaseAuth.currentUser.photoURL;
    if (photoURL == null) {
      photoURL = '/assets/user_image_placeholder.png';
    }
    _firestoreInstance = firebase.firestore();
    _docStorage = FirebaseDocStorage(_firestoreInstance);
    _pubsubInstance = new PubSubClient(platform_constants.publishUrl, user);
    controller.command(controller.UIAction.userSignedIn, new controller.UserData(user.displayName, user.email, photoURL));
  }, (){
    controller.command(controller.UIAction.userSignedOut, null);
  });
}

void listenForSuggestedReplies(SuggestedReplyCollectionListener listener, [OnErrorListener onErrorListener]) =>
    SuggestedReply.listen(_docStorage, listener, onErrorListener: onErrorListener);

Future<void> updateSuggestedReplies(List<SuggestedReply> replies) {
  List<Future> futures = [];

  for (SuggestedReply suggestedReply in replies) {
    futures.add(_pubsubInstance.publishAddOpinion('nook/set_suggested_reply', {
      "__id": suggestedReply.suggestedReplyId,
      "text": suggestedReply.text,
      "translation": suggestedReply.translation,
      "shortcut": suggestedReply.shortcut,
      "seq_no": suggestedReply.seqNumber,
      "category": suggestedReply.category,
      "group_id": suggestedReply.groupId,
      "group_description": suggestedReply.groupDescription,
      "index_in_group": suggestedReply.indexInGroup
    }));
  }

  return Future.wait(futures);
}

// TODO: When the message | conv tag merging logic has landed, replace the collection path
void listenForTags(TagCollectionListener listener, [OnErrorListener onErrorListener]) =>
    Tag.listen(_docStorage, listener, "conversationTags", onErrorListener: onErrorListener);

Future<void> updateTags(List<Tag> tags) {
  List<Future> futures = [];
  for (Tag tag in tags) {
    futures.add(_pubsubInstance.publishAddOpinion('nook/set_tag', tag.toData()..putIfAbsent('__id', () => tag.tagId)));
  }

  return Future.wait(futures);
}
