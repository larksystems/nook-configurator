import 'dart:html';

import 'logger.dart';
import 'controller.dart' as controller;

Logger log = new Logger('view.dart');

Element get headerElement => querySelector('header');
Element get mainElement => querySelector('main');
Element get footerElement => querySelector('footer');

NavView navView;
ContentView contentView;

void init() {
  navView = new NavView();
  contentView = new ContentView();
  headerElement.append(navView.navViewElement);
  mainElement.append(contentView.contentViewElement);
}

class NavView {
  DivElement navViewElement;
  DivElement _appLogos;
  DivElement _navLinks;
  DivElement _projectTitle;
  DivElement _projectOrganizations;
  AuthHeaderViewPartial authHeaderViewPartial;
  ButtonElement _backBtn;
  AnchorElement _allProjectsLink;

  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/africas-voices-logo.svg'));
    _backBtn = new ButtonElement()
      ..classes.add('nav-links__back-btn')
      ..text = '< Back'
      ..onClick.listen((_) => window.history.back());
    _allProjectsLink = new AnchorElement()
      ..classes.add('nav-links__all-projects-link')
      ..href = '#/project-selector'
      ..text = 'All projects';
    _navLinks = new DivElement()
      ..classes.add('nav-links');
      // ..append(_backBtn)
      // ..append(_allProjectsLink);
    _projectTitle = new DivElement()
      ..classes.add('nav-project-details__title');
    _projectOrganizations = new DivElement()
      ..classes.add('nav-project-details__organization');
    var projectDetails = new DivElement()
      ..classes.add('nav-project-details')
      ..append(_projectTitle)
      ..append(_projectOrganizations);
    authHeaderViewPartial = new AuthHeaderViewPartial();

    navViewElement.append(_appLogos);
    navViewElement.append(_navLinks);
    navViewElement.append(projectDetails);
    navViewElement.append(authHeaderViewPartial.authElement);
  }

  Element get backBtn => _backBtn;

  Element get allProjectsLink => _allProjectsLink;

  void set projectTitle(String projectName) => _projectTitle.text = projectName;

  void set projectOrganizations(List<String> organizations) => _projectOrganizations.text = organizations?.first;
}

class AuthHeaderViewPartial {
  DivElement authElement;
  DivElement _userPic;
  DivElement _userName;
  ButtonElement _signOutButton;
  ButtonElement _signInButton;

  AuthHeaderViewPartial() {
    authElement = new DivElement()
      ..classes.add('auth-header');

    _userPic = new DivElement()
      ..classes.add('auth-header__user-pic');
    authElement.append(_userPic);

    _userName = new DivElement()
      ..classes.add('auth-header__user-name');
    authElement.append(_userName);

    _signOutButton = new ButtonElement()
      ..text = 'Sign out'
      ..onClick.listen((_) => controller.command(controller.UIAction.signOutButtonClicked, null));
    authElement.append(_signOutButton);

    _signInButton = new ButtonElement()
      ..text = 'Sign in'
      ..onClick.listen((_) => controller.command(controller.UIAction.signInButtonClicked, null));
    authElement.append(_signInButton);
  }

  void signIn(String userName, userPicUrl) {
    // Set the user's profile pic and name
    _userPic.style.backgroundImage = 'url($userPicUrl)';
    _userName.text = userName;

    // Show user's profile pic, name and sign-out button.
    _userName.attributes.remove('hidden');
    _userPic.attributes.remove('hidden');
    _signOutButton.attributes.remove('hidden');

    // Hide sign-in button.
    _signInButton.setAttribute('hidden', 'true');
  }

  void signOut() {
    // Hide user's profile pic, name and sign-out button.
    _userName.attributes['hidden'] = 'true';
    _userPic.attributes['hidden'] = 'true';
    _signOutButton.attributes['hidden'] = 'true';

    // Show sign-in button.
    _signInButton.attributes.remove('hidden');
  }
}

abstract class BaseView {
  DivElement get renderElement;
}

class ContentView {
  DivElement contentViewElement;

  BaseView renderedView;

  ContentView() {
    contentViewElement = new DivElement()..classes.add('content');
  }

  void renderView(BaseView view) {
    contentViewElement.children.clear();
    contentViewElement.append(view.renderElement);
    renderedView = view;
  }
}

class AuthMainView extends BaseView {
  DivElement authElement;
  ButtonElement _signInButton;

  final descriptionText1 = 'Sign in to Katikati';
  final descriptionText2 = 'Please contact Africa\'s Voices for login details.';

  AuthMainView() {
    authElement = new DivElement()
      ..classes.add('auth-main');

    var logosContainer = new DivElement()
      ..classes.add('auth-main__logos');
    authElement.append(logosContainer);

    var avfLogo = new ImageElement(src: 'assets/africas-voices-logo.svg')
      ..classes.add('auth-main__partner-logo');
    logosContainer.append(avfLogo);

    var shortDescription = new DivElement()
      ..classes.add('auth-main__project-description')
      ..append(new ParagraphElement()..text = descriptionText1)
      ..append(new ParagraphElement()..text = descriptionText2);
    authElement.append(shortDescription);

    _signInButton = new ButtonElement()
      ..text = 'Sign in'
      ..onClick.listen((_) => controller.command(controller.UIAction.signInButtonClicked, null));
    authElement.append(_signInButton);
  }

  DivElement get renderElement => authElement;
}

class PackageConfiguratorView extends BaseView {
  SuggestedRepliesView suggestedRepliesView;

  DivElement _packageConfiguratorViewElement;
  DivElement _packageConfiguratorContent;

  PackageConfiguratorView() {
    suggestedRepliesView = new SuggestedRepliesView();

    _packageConfiguratorViewElement = new DivElement()
      ..classes.add('configure-package-view');
    _packageConfiguratorContent = new DivElement()
      ..classes.add('configure-package-content');
    _buildContentPartial(_packageConfiguratorContent);
    _packageConfiguratorViewElement.append(_packageConfiguratorContent);
  }

  DivElement get renderElement => _packageConfiguratorViewElement;

  void _buildContentPartial(DivElement packageConfiguratorContent) {
    packageConfiguratorContent
      ..append(
        new DivElement()
          ..classes.add('configure-package-suggested-replies')
          ..append(
            new DivElement()
              ..classes.add('configure-package-suggested-replies-headers')
              ..append(
                new HeadingElement.h3()
                  ..text = 'What do you want to say?'
              )
          )
          ..append(suggestedRepliesView.renderElement)
      )
      ..append(
        new DivElement()
          ..classes.add('configure-package-actions')
          ..append(
            new ButtonElement()
              ..classes.add('save-configuration-btn')
              ..text = 'Save Configuration'
              ..onClick.listen((_) => controller.command(controller.UIAction.savePackageConfiguration))
          )
      );
  }
}

class SuggestedReplyMessageView {
  Element _suggestedReplyMessageElement;
  Function onUpdateSuggestedReplyCallback;

  SuggestedReplyMessageView(int index, String suggestedReply, this.onUpdateSuggestedReplyCallback) {
    var suggestedReplyCounter = new SpanElement()
      ..classes.add('conversation-suggested-reply-language__text-count')
      ..classes.toggle('conversation-suggested-reply-language__text-count--alert', suggestedReply.length > 160)
      ..text = '${suggestedReply.length}/160';
    var suggestedReplyText = new ParagraphElement();
    suggestedReplyText
      ..classes.add('conversation-suggested-reply-language__text')
      ..classes.toggle('conversation-suggested-reply-language__text--alert', suggestedReply.length > 160)
      ..text = suggestedReply != null ? suggestedReply : ''
      ..contentEditable = 'true'
      ..dataset['index'] = '$index'
      ..onBlur.listen((event) => onUpdateSuggestedReplyCallback(index, (event.target as Element).text))
      ..onInput.listen((event) {
        int count = suggestedReplyText.text.split('').length;
        suggestedReplyCounter.text = '${count}/160';
        suggestedReplyText.classes.toggle('conversation-suggested-reply-language__text--alert', count > 160);
        suggestedReplyCounter.classes.toggle('conversation-suggested-reply-language__text-count--alert', count > 160);
      });
    _suggestedReplyMessageElement = new DivElement()
      ..classes.add('conversation-suggested-reply-language')
      ..append(suggestedReplyText)
      ..append(suggestedReplyCounter);
  }

  Element get renderElement => _suggestedReplyMessageElement;
}

class SuggestedReplyView {
  Element _suggestedReplyElement;

  SuggestedReplyView(String id, String text, String translation) {
    _suggestedReplyElement = new DivElement()
      ..classes.add('conversation-suggested-reply')
      ..dataset['id'] = '$id'
      ..append(
        new ButtonElement()
          ..classes.add('button-remove-conversation-suggested-replies')
          ..text = 'x'
          ..onClick.listen((_) {
            var removeSuggestedRepliesModal = new DivElement()
              ..classes.add('remove-conversation-suggested-replies-modal');
            removeSuggestedRepliesModal
              ..append(
                new ParagraphElement()
                  ..classes.add('remove-conversation-suggested-replies-modal__message')
                  ..text = 'Are you sure?'
              )
              ..append(
                new DivElement()
                  ..classes.add('remove-conversation-suggested-replies-modal-actions')
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-suggested-replies-modal-actions__action')
                      ..text = 'Yes'
                      ..onClick.listen((_) => controller.command(controller.UIAction.removeSuggestedReply, new controller.SuggestedReplyData(id)))
                  )
                  ..append(
                    new ButtonElement()
                      ..classes.add('remove-conversation-suggested-replies-modal-actions__action')
                      ..text = 'No'
                      ..onClick.listen((_) => removeSuggestedRepliesModal.remove())
                  )
              );
          })
        )
      ..append(new SuggestedReplyMessageView(0, text, (index, text) => controller.command(controller.UIAction.updateSuggestedReply, new controller.SuggestedReplyData(id, text: text))).renderElement)
      ..append(new SuggestedReplyMessageView(0, translation, (index, translation) => controller.command(controller.UIAction.updateSuggestedReply, new controller.SuggestedReplyData(id, translation: translation))).renderElement);
  }

  Element get renderElement => _suggestedReplyElement;
}

class SuggestedReplyGroupView {
  DivElement _suggestedRepliesGroupElement;
  DivElement _suggestedRepliesContainer;

  SuggestedReplyGroupView(String groupName) {
    _suggestedRepliesGroupElement = new DivElement()
      ..classes.add('conversation-suggested-reply-group');

    var title = new SpanElement();
    title
      ..classes.add('conversation-suggested-reply-group__title')
      ..text = groupName
      ..title = '<group name>'
      ..contentEditable = 'true'
      ..onBlur.listen((event) => controller.command(controller.UIAction.updateSuggestedReplyGroup, new controller.SuggestedReplyGroupData(groupName, newName: title.text)));
    _suggestedRepliesGroupElement.append(title);

    _suggestedRepliesContainer = new DivElement()
      ..classes.add('conversation-suggested-reply-container');
    _suggestedRepliesGroupElement.append(_suggestedRepliesContainer);

    var addButton = new ButtonElement()
      ..classes.add('button-add-conversation-suggested-replies')
      ..text = '+'
      ..title = 'Add new suggested reply'
      ..onClick.listen((event) => controller.command(controller.UIAction.addSuggestedReply));
    _suggestedRepliesGroupElement.append(addButton);
  }

  Element get renderElement => _suggestedRepliesGroupElement;

  void addReply(SuggestedReplyView suggestedReplyView) {
    _suggestedRepliesContainer.append(suggestedReplyView.renderElement);
  }
}

class SuggestedRepliesView extends BaseView {
  DivElement _suggestedRepliesElement;
  DivElement _suggestedRepliesContainer;
  SelectElement _replyCategories;

  SuggestedRepliesView() {
    _suggestedRepliesElement = new DivElement()
      ..classes.add('conversation-suggested-replies');

    _replyCategories = new SelectElement();
    _replyCategories.onChange.listen((_) => controller.command(controller.UIAction.changeSuggestedRepliesCategory, new controller.SuggestedRepliesCategoryData(_replyCategories.value)));
    _suggestedRepliesElement.append(_replyCategories);

    _suggestedRepliesContainer = new DivElement();
    _suggestedRepliesElement.append(_suggestedRepliesContainer);

    var addButton = new ButtonElement()
      ..classes.add('button-add-conversation-suggested-replies')
      ..text = '+'
      ..title = 'Add a new group of suggested replies'
      ..onClick.listen((event) => controller.command(controller.UIAction.addSuggestedReplyGroup));
    _suggestedRepliesElement.append(addButton);
  }

  DivElement get renderElement => _suggestedRepliesElement;

  void addReplyGroup(SuggestedReplyGroupView suggestedReplyGroupView) {
    _suggestedRepliesContainer.append(suggestedReplyGroupView.renderElement);
  }

  set selectedCategory(String category) {
    int index = _replyCategories.children.indexWhere((Element option) => (option as OptionElement).value == category);
    if (index == -1) {
      // Couldn't find category in list of suggested replies category, using first
      _replyCategories.selectedIndex = 0;
      controller.command(controller.UIAction.changeSuggestedRepliesCategory, new controller.SuggestedRepliesCategoryData(_replyCategories.value));
      return;
    }
    _replyCategories.selectedIndex = index;
  }

  set categories(List<String> categories) {
    _replyCategories.children.clear();
    for (var category in categories) {
      _replyCategories.append(
        new OptionElement()
          ..value = category
          ..text = category);
    }
  }

  void clear() {
    int repliesNo = _suggestedRepliesContainer.children.length;
    for (int i = 0; i < repliesNo; i++) {
      _suggestedRepliesContainer.firstChild.remove();
    }
    assert(_suggestedRepliesContainer.children.length == 0);
  }
}
