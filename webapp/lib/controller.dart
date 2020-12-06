library controller;


import 'dart:html';

import 'package:nook/model.dart' as new_model;

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';
import 'model.dart' as model;

part 'controller_view_helper.dart';

Logger log = new Logger('controller.dart');
Router router;

enum UIAction {
  userSignedIn,
  userSignedOut,
  signInButtonClicked,
  signOutButtonClicked,
  savePackageConfiguration,
}

class Data {}

class UserData extends Data {
  String displayName;
  String email;
  String photoUrl;
  UserData(this.displayName, this.email, this.photoUrl);

  @override
  String toString() {
    return "UserData($displayName, $email, $photoUrl)";
  }
}

List<String> configurationSuggestedReplyLanguages;
List<new_model.SuggestedReply> suggestedReplies;
Map<String, List<new_model.SuggestedReply>> suggestedRepliesByCategory;

model.User signedInUser;
final String selectedPackage = 'Change communications';

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  router.routeTo(window.location.hash);

  // Listener inits
  suggestedReplies = [];


    platform.listenForSuggestedReplies(
    (added, modified, removed) {
      var updatedIds = new Set()
        ..addAll(added.map((r) => r.suggestedReplyId))
        ..addAll(modified.map((r) => r.suggestedReplyId))
        ..addAll(removed.map((r) => r.suggestedReplyId));
      suggestedReplies.removeWhere((suggestedReply) => updatedIds.contains(suggestedReply.suggestedReplyId));
      suggestedReplies
        ..addAll(added)
        ..addAll(modified);

      // Update the replies by category map
      suggestedRepliesByCategory = _groupRepliesIntoCategories(suggestedReplies);
      // Empty sublist if there are no replies to show
      if (suggestedRepliesByCategory.isEmpty) {
        suggestedRepliesByCategory[''] = [];
      }
      // Sort by sequence number
      for (var replies in suggestedRepliesByCategory.values) {
        replies.sort((r1, r2) {
          var seqNo1 = r1.seqNumber == null ? double.nan : r1.seqNumber;
          var seqNo2 = r2.seqNumber == null ? double.nan : r2.seqNumber;
          return seqNo1.compareTo(seqNo2);
        });
      }
      List<String> categories = suggestedRepliesByCategory.keys.toList();
      categories.sort((c1, c2) => c1.compareTo(c2));

      // TODO: Do something with this, code from Nook below for reference

      // Replace list of categories in the UI selector
      // view.replyPanelView.categories = categories;
      // If the categories have changed under us and the selected one no longer exists,
      // default to the first category, whichever it is
      // if (!categories.contains(selectedSuggestedRepliesCategory)) {
        // selectedSuggestedRepliesCategory = categories.first;
      // }
      // Select the selected category in the UI and add the suggested replies for it
      // view.replyPanelView.selectedCategory = selectedSuggestedRepliesCategory;
      // _populateReplyPanelView(suggestedRepliesByCategory[selectedSuggestedRepliesCategory]);
    // }, showAndLogError);
  });
}

void setupRoutes() {
  router = new Router()
    ..addAuthHandler(new Route('#/auth', loadAuthView))
    ..addDefaultHandler(new Route('#/configuration', loadPackageConfigurationView))
    ..listen();
}

void command(UIAction action, Data actionData) {
  log.verbose('command => $action : $actionData');
  switch (action) {
    case UIAction.userSignedIn:
      UserData userData = actionData;
      signedInUser = new model.User()
        ..userName = userData.displayName
        ..userEmail = userData.email;
      view.navView.authHeaderViewPartial.signIn(userData.displayName, userData.photoUrl);
      initUI();
      break;
    case UIAction.userSignedOut:
      signedInUser = null;
      view.navView.authHeaderViewPartial.signOut();
      view.navView.projectTitle = '';
      router.routeTo('#/auth');
      break;
    case UIAction.signInButtonClicked:
      platform.signIn();
      break;
    case UIAction.signOutButtonClicked:
      platform.signOut();
      break;
    case UIAction.savePackageConfiguration:
      savePackageConfiguration();
      break;
  }
}

void loadAuthView() {
  view.contentView.renderView(new view.AuthMainView());
}

void savePackageConfiguration() {
}

void loadPackageConfigurationView() {
  var configuratorView = new view.PackageConfiguratorView(model.packageConfigurationData[selectedPackage]);
  view.contentView.renderView(configuratorView);
}

// Suggested Replies operations
void addNewSuggestedReply() {
  model.packageConfigurationData[selectedPackage].suggestedReplies.add(
    {
      "messages":
        [
          "",
          "",
        ],
      "reviewed": false,
      "reviewed-by": "",
      "reviewed-date": ""
    },
  );
  loadPackageConfigurationView();
}

void updateSuggestedReply(int rowIndex, int colIndex, String suggestedReply) {
  model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['messages'][colIndex] = suggestedReply;
  loadPackageConfigurationView();
}

void reviewSuggestedReply(int rowIndex, bool reviewed) {
  if (reviewed) {
    var now = DateTime.now().toLocal();
    var reviewedDate = '${now.year}-${now.month}-${now.day}';
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed'] = true;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-by'] = signedInUser.userEmail;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-date'] = reviewedDate;
  } else {
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed'] = false;
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-by'] = '';
    model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['reviewed-date'] = '';
  }
  loadPackageConfigurationView();
}

void removeSuggestedReply(int rowIndex) {
  model.packageConfigurationData[selectedPackage].suggestedReplies.removeAt(rowIndex);
  loadPackageConfigurationView();
}

Future<void> saveSuggestedReplies(List<new_model.SuggestedReply> suggestedReplies) {
  return platform.updateSuggestedReplies(suggestedReplies);
}
