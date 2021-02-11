library view;

import 'dart:async';
import 'dart:html';

import 'package:dnd/dnd.dart' as dnd;

import 'package:katikati_ui_lib/components/logger.dart';
import 'controller.dart' as controller;
import 'platform.dart' as platform;

import 'sample_data_helper.dart';

part 'view_messages.dart';
part 'view_tags.dart';

Logger log = new Logger('view.dart');

Element get headerElement => querySelector('header');
Element get mainElement => querySelector('main');
Element get footerElement => querySelector('footer');

NavView navView;
PageRenderer contentView;

void init() {
  navView = new NavView();
  contentView = new PageRenderer();
  headerElement.append(navView.navViewElement);
  mainElement.append(contentView.contentElement);
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
    navViewElement = new DivElement()..classes.add('nav');
    _appLogos = new DivElement()
      ..classes.add('nav__app-logo')
      ..append(new ImageElement(src: 'assets/logo-katikati.svg', height: 26))
      ..append(new ImageElement(src: 'assets/logo-ifrc.svg', height: 26));
    _backBtn = new ButtonElement()
      ..classes.add('nav-links__back-btn')
      ..text = '< Back'
      ..onClick.listen((_) => window.history.back());
    _allProjectsLink = new AnchorElement()
      ..classes.add('nav-links__all-projects-link')
      ..href = '#/project-selector'
      ..text = 'All projects';
    _navLinks = new DivElement()..classes.add('nav-links');
    // ..append(_backBtn)
    // ..append(_allProjectsLink);
    _projectTitle = new DivElement()..classes.add('nav-project-details__title');
    _projectOrganizations = new DivElement()..classes.add('nav-project-details__organization');
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
    authElement = new DivElement()..classes.add('auth-header');

    _userPic = new DivElement()..classes.add('auth-header__user-pic');
    authElement.append(_userPic);

    _userName = new DivElement()..classes.add('auth-header__user-name');
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

class PageRenderer {
  DivElement contentElement;

  PageView renderedPage;

  PageRenderer() {
    contentElement = new DivElement()..classes.add('content');
  }

  void renderView(PageView view) {
    contentElement.children.clear();
    contentElement.append(view.renderElement);
    renderedPage = view;
  }
}

abstract class PageView {
  Element get renderElement;
}

/// The authentication page
class AuthPage extends PageView {
  DivElement authElement;
  ButtonElement _signInButton;

  final descriptionText1 = 'Sign in to Katikati';

  AuthPage() {
    authElement = new DivElement()..classes.add('auth-main');

    var logosContainer = new DivElement()..classes.add('auth-main__logos');
    authElement.append(logosContainer);

    var katikatiLogo = new ImageElement(src: 'assets/logo-katikati.svg')..classes.add('auth-main__partner-logo');
    logosContainer.append(katikatiLogo);
    var ifrcLogo = new ImageElement(src: 'assets/logo-ifrc.svg')..classes.add('auth-main__partner-logo');
    logosContainer.append(ifrcLogo);

    var shortDescription = new DivElement()
      ..classes.add('auth-main__project-description')
      ..append(new ParagraphElement()..text = descriptionText1);
    authElement.append(shortDescription);

    _signInButton = new ButtonElement()
      ..text = 'Sign in'
      ..onClick.listen((_) => controller.command(controller.UIAction.signInButtonClicked, null));
    authElement.append(_signInButton);
  }

  DivElement get renderElement => authElement;
}

/// The page for selecting between the configuration pages
class ConfigurationSelectionPage extends PageView {
  DivElement renderElement;

  ConfigurationSelectionPage(
      List<controller.PageInfo> conversePages,
      List<controller.PageInfo> configurePages,
      List<controller.PageInfo> comprehendPages) {
    renderElement = new DivElement()..classes.add('configuration-view');

    {
      var title = new DivElement()
        ..classes.add('configuration-view__title')
        ..text = 'Converse';
      renderElement.append(title);


      DivElement pageContent = new DivElement()
        ..classes.add('configuration-view__content')
        ..classes.add('config-page-options');
      renderElement.append(pageContent);
      for (var page in conversePages) {
        var button  = Button(ButtonType.contained, buttonText: page.goToButtonText, onClick: (_) {
          controller.router.routeTo(page.urlPath);
        });
        button.renderElement.classes.add('config-page-option__action');
        button.parent = pageContent;

        var description = new SpanElement()
          ..classes.add('config-page-option__description')
          ..text = page.shortDescription;
        pageContent..append(description);
      }
    }

    {
      var title = new DivElement()
        ..classes.add('configuration-view__title')
        ..text = 'Configure';
      renderElement.append(title);


      DivElement pageContent = new DivElement()
        ..classes.add('configuration-view__content')
        ..classes.add('config-page-options');
      renderElement.append(pageContent);
      for (var page in configurePages) {
        var button  = Button(ButtonType.contained, buttonText: page.goToButtonText, onClick: (_) {
          controller.router.routeTo(page.urlPath);
        });
        button.renderElement.classes.add('config-page-option__action');
        button.parent = pageContent;

        var description = new SpanElement()
          ..classes.add('config-page-option__description')
          ..text = page.shortDescription;
        pageContent..append(description);
      }
    }

    {
      var title = new DivElement()
        ..classes.add('configuration-view__title')
        ..text = 'Comprehend';
      renderElement.append(title);


      DivElement pageContent = new DivElement()
        ..classes.add('configuration-view__content')
        ..classes.add('config-page-options');
      renderElement.append(pageContent);
      for (var page in comprehendPages) {
        var button  = Button(ButtonType.contained, buttonText: page.goToButtonText, onClick: (_) {
          controller.router.routeTo(page.urlPath);
        });
        button.renderElement
          ..classes.add('config-page-option__action')
          ..classes.add('config-page-option__action--disabled');
        button.parent = pageContent;

        var description = new SpanElement()
          ..classes.add('config-page-option__description')
          ..text = page.shortDescription;
        pageContent..append(description);
      }
    }
  }
}

/// An empty page to be inherited to create different options for configuring,
/// (e.g. tags or messages), and a save button with an indicator.
class ConfigurationPage extends PageView {
  DivElement renderElement;
  DivElement _configurationTitle;
  DivElement _configurationContent;

  DivElement _configurationActions;
  ButtonElement _saveConfigurationButton;
  SpanElement _saveStatusElement;

  ConfigurationPage() {
    renderElement = new DivElement()..classes.add('configuration-view');

    var backPageLink = new Element.a()
      ..classes.add('configuration-view__back-link')
      ..text = 'Back to the main configuration page'
      ..onClick.listen((event) => controller.router.routeTo(controller.pages[controller.SELECT_CONFIG_PAGE].urlPath));
    renderElement.append(backPageLink);

    _configurationTitle = new DivElement()..classes.add('configuration-view__title');
    renderElement.append(_configurationTitle);

    _configurationContent = new DivElement()..classes.add('configuration-view__content');
    renderElement.append(_configurationContent);

    _configurationActions = new DivElement()..classes.add('configuration-actions');
    renderElement.append(_configurationActions);

    _saveConfigurationButton = new ButtonElement()
      ..classes.add('configuration-actions__save-action')
      ..text = 'Save Configuration'
      ..onClick.listen((_) => controller.command(controller.UIAction.saveConfiguration));
    _configurationActions.append(_saveConfigurationButton);

    _saveStatusElement = new SpanElement()..classes.add('configuration-actions__save-action__status');
    _configurationActions.append(_saveStatusElement);
  }

  /// How many seconds the save status will be displayed on screen before disappearing.
  static const _SECONDS_ON_SCREEN = 5;

  /// The length of the animation in milliseconds.
  /// This must match the animation length set in snackbar.css
  static const _ANIMATION_LENGTH_MS = 200;

  void showSaveStatus(String status) {
    _saveStatusElement.text = status;
    _saveStatusElement.classes.remove('hidden');
    new Timer(new Duration(seconds: _SECONDS_ON_SCREEN), () => hideSaveStatus());
  }

  hideSaveStatus() {
    _saveStatusElement.classes.toggle('hidden', true);
    // Remove the contents after the animation ends
    new Timer(new Duration(milliseconds: _ANIMATION_LENGTH_MS), () => _saveStatusElement.text = '');
  }
}

/// Helper widgets

typedef void OnEventCallback(Event e);

enum ButtonType {
  // Text buttons
  text,
  outlined,
  contained,

  // Icon buttons
  add,
  remove,
  confirm,
  edit,
}

class ButtonAction {
  String buttonText;
  OnEventCallback onClick;

  ButtonAction(this.buttonText, this.onClick);
}

class Button {
  ButtonElement _element;

  Button(ButtonType buttonType, {String buttonText = '', String hoverText = '', OnEventCallback onClick}) {
    _element = new ButtonElement()
      ..classes.add('button')
      ..title = hoverText;

    onClick = onClick ?? (_) {};
    _element.onClick.listen(onClick);

    switch (buttonType) {
      case ButtonType.text:
        _element.classes.add('button--text');
        _element.text = buttonText;
        break;
      case ButtonType.outlined:
        _element.classes.add('button--outlined');
        _element.text = buttonText;
        break;
      case ButtonType.contained:
        _element.classes.add('button--contained');
        _element.text = buttonText;
        break;

      case ButtonType.add:
        _element.classes.add('button--add');
        break;
      case ButtonType.remove:
        _element.classes.add('button--remove');
        break;
      case ButtonType.confirm:
        _element.classes.add('button--confirm');
        break;
      case ButtonType.edit:
        _element.classes.add('button--edit');
        break;
    }
  }

  Element get renderElement => _element;

  void set visible(bool value) {
    _element.classes.toggle('hidden', !value);
  }

  void set parent(Element value) => value.append(_element);
  void remove() => _element.remove();
}

class InlineOverlayModal {
  DivElement inlineOverlayModal;

  InlineOverlayModal(String message, List<Button> buttons) {
    inlineOverlayModal = new DivElement()..classes.add('inline-overlay-modal');

    inlineOverlayModal.append(new ParagraphElement()
      ..classes.add('inline-overlay-modal__message')
      ..text = message);

    var actions = new DivElement()..classes.add('inline-overlay-modal__actions');
    inlineOverlayModal.append(actions);
    for (var button in buttons) {
      button.parent = actions;
    }
  }

  void set parent(Element value) => value.append(inlineOverlayModal);
  void remove() => inlineOverlayModal.remove();
}

class PopupModal {
  DivElement popupModal;

  PopupModal(String message, List<Button> buttons) {
    popupModal = new DivElement()..classes.add('popup-modal');

    popupModal.append(new ParagraphElement()
      ..classes.add('popup-modal__message')
      ..text = message);

    var actions = new DivElement()..classes.add('popup-modal__actions');
    popupModal.append(actions);
    for (var button in buttons) {
      button.parent = actions;
    }
  }

  void set parent(Element value) => value.append(popupModal);
  void remove() => popupModal.remove();
}

class EditableText {
  DivElement editableWrapper;

  Button _editButton;
  Button _removeButton;
  Button _saveButton;
  Button _cancelButton;

  String _textBeforeEdit;
  bool _duringEdit;

  EditableText(Element textElementToEdit, {bool alwaysShowButtons: false, OnEventCallback onEditStart, OnEventCallback onEditEnd, OnEventCallback onSave, OnEventCallback onRemove}) {
    editableWrapper = new DivElement()..classes.add('editable-widget');
    if (alwaysShowButtons)
      editableWrapper..classes.add('editable-widget--always-show-buttons');
    editableWrapper.append(textElementToEdit);

    onEditStart = onEditStart ?? (_) {};
    onEditEnd = onEditEnd ?? (_) {};
    onSave = onSave ?? (_) {};
    onRemove = onRemove ?? (_) {};

    _duringEdit = false;
    var saveEdits = (e) {
      if (!_duringEdit) return;
      _duringEdit = false;

      _editButton.parent = editableWrapper;
      _removeButton.parent = editableWrapper;
      _saveButton.remove();
      _cancelButton.remove();

      textElementToEdit.contentEditable = 'false';
      onEditEnd(e);
      onSave(e);
    };

    var cancelEdits = (e) {
      if (!_duringEdit) return;
      _duringEdit = false;

      _editButton.parent = editableWrapper;
      _removeButton.parent = editableWrapper;
      _saveButton.remove();
      _cancelButton.remove();

      textElementToEdit.contentEditable = 'false';
      textElementToEdit.text = _textBeforeEdit;
      onEditEnd(e);
    };

    var startEditing = (e) {
      _duringEdit = true;

      _editButton.remove();
      _removeButton.remove();
      _saveButton.parent = editableWrapper;
      _cancelButton.parent = editableWrapper;

      _textBeforeEdit = textElementToEdit.text;
      _makeEditable(textElementToEdit, onEsc: cancelEdits, onEnter: (e) {
        e.stopPropagation();
        e.preventDefault();
        saveEdits(e);
      });
      onEditStart(e);
      textElementToEdit.focus();
    };

    _editButton = new Button(ButtonType.edit, onClick: startEditing);
    _editButton.parent = editableWrapper;

    _removeButton = new Button(ButtonType.remove, onClick: onRemove);
    _removeButton.renderElement.classes.add('button--on-hover-red');
    _removeButton.parent = editableWrapper;

    _saveButton = new Button(ButtonType.confirm, onClick: saveEdits);
    _saveButton.renderElement.classes.add('button--green');
    _cancelButton = new Button(ButtonType.remove, onClick: cancelEdits);
  }

  void set parent(Element value) => value.append(editableWrapper);
  void remove() => editableWrapper.remove();
}

void _makeEditable(Element element, {OnEventCallback onBlur, OnEventCallback onEnter, OnEventCallback onEsc}) {
  element
    ..contentEditable = 'true'
    ..onBlur.listen((e) {
      e.stopPropagation();
      if (onBlur != null) onBlur(e);
    })
    ..onKeyPress.listen((e) => e.stopPropagation())
    ..onKeyUp.listen((e) => e.stopPropagation())
    ..onKeyDown.listen((e) {
      e.stopPropagation();
      if (onEnter != null && e.keyCode == KeyCode.ENTER) {
        onEnter(e);
        return;
      }
      if (onEsc != null && e.keyCode == KeyCode.ESC) {
        onEsc(e);
        return;
      }
    });
}
