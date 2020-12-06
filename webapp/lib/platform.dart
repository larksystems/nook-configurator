import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;

import 'controller.dart' as controller;
import 'logger.dart';
import 'package:nook/platform_constants.dart' as platform_constants;
import 'package:nook/pubsub.dart';
import 'package:nook/model.dart';
import 'package:nook/model_firebase.dart';


Logger log = new Logger('platform.dart');

firestore.Firestore _firestoreInstance;

DocStorage _docStorage;
PubSubClient _pubsubInstance;
PubSubClient _uptimePubSubInstance;


init() async {
  await platform_constants.init();

  firebase.initializeApp(
    apiKey: platform_constants.apiKey,
    authDomain: platform_constants.authDomain,
    databaseURL: platform_constants.databaseURL,
    projectId: platform_constants.projectId,
    storageBucket: platform_constants.storageBucket,
    messagingSenderId: platform_constants.messagingSenderId);

  // Firebase login
  firebaseAuth.onAuthStateChanged.listen((firebase.User user) async {
    if (user == null) { // User signed out
      controller.command(controller.UIAction.userSignedOut, null);
      return;
    }
    // User signed in
    String photoURL = firebaseAuth.currentUser.photoURL;
    if (photoURL == null) {
      photoURL =  '/assets/user_image_placeholder.png';
    }
    _firestoreInstance = firebase.firestore();
    _docStorage = FirebaseDocStorage(_firestoreInstance);
    _pubsubInstance = new PubSubClient(platform_constants.publishUrl, user);
    controller.command(controller.UIAction.userSignedIn, new controller.UserData(user.displayName, user.email, photoURL));
  });
}

firebase.Auth get firebaseAuth => firebase.auth();

/// Signs the user in.
signIn() {
  var provider = new firebase.GoogleAuthProvider();
  firebaseAuth.signInWithPopup(provider);
}

/// Signs the user out.
signOut() {
  firebaseAuth.signOut();
}

/// Returns true if a user is signed-in.
bool isUserSignedIn() {
  return firebaseAuth.currentUser != null;
}

void listenForSuggestedReplies(SuggestedReplyCollectionListener listener, [OnErrorListener onErrorListener]) =>
    SuggestedReply.listen(_docStorage, listener, onErrorListener: onErrorListener);

Future<void> updateSuggestedReplies(List<SuggestedReply> replies) {
  print ("TODO: Set Suggeted");
  return Future.value(0);
}
