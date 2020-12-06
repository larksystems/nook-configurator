library controller;

import 'dart:html';

import 'logger.dart';
import 'platform.dart' as platform;
import 'view.dart' as view;
import 'router.dart';
import 'model.dart' as model;

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

List<String> configurationResponseLanguages;

model.User signedInUser;
final String selectedPackage = 'Change communications';

void init() async {
  setupRoutes();
  view.init();
  await platform.init();
}

void initUI() {
  router.routeTo(window.location.hash);
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
void addNewResponse() {
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

void updateResponse(int rowIndex, int colIndex, String response) {
  model.packageConfigurationData[selectedPackage].suggestedReplies[rowIndex]['messages'][colIndex] = response;
  loadPackageConfigurationView();
}

void reviewResponse(int rowIndex, bool reviewed) {
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

void removeResponse(int rowIndex) {
  model.packageConfigurationData[selectedPackage].suggestedReplies.removeAt(rowIndex);
  loadPackageConfigurationView();
}
