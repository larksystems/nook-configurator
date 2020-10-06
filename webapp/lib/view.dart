import 'dart:convert';
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
  DivElement appLogos;
  DivElement projectTitle;

  NavView() {
    navViewElement = new DivElement()
      ..classes.add('nav');
    appLogos = new DivElement()
      ..classes.add('nav__app-logo');
    projectTitle = new DivElement()
      ..classes.add('nav__project-title')
      ..append(new SpanElement()..text = 'COVID IMAQAL Batch replies (Week 12)');

    appLogos.append(new ImageElement(src: 'assets/africas-voices-logo.svg'));

    navViewElement.append(appLogos);
    navViewElement.append(projectTitle);
  }
}

class ContentView {
  DivElement contentViewElement;
  DashboardView dashboardView;
  ConfigurationView configurationView;

  ContentView() {
    contentViewElement = new DivElement()..classes.add('content');
    dashboardView = new DashboardView();
    configurationView = new ConfigurationView();
  }

  void renderView(DivElement view) {
    contentViewElement.children.clear();
    contentViewElement.append(view);
  }
}

class DashboardView {
  List<ActivePackagesViewPartial> activePackages;
  List<AvailablePackagesViewPartial> availablepackages;

  DivElement dashboardViewElement;
  DivElement _projectActionsContainer;
  AnchorElement _conversationsLink;
  AnchorElement _oversightDashboardLink;
  DivElement activePackagesContainer;
  DivElement availablePackagesContainer;

  DashboardView() {
    activePackages = [];
    availablepackages = [];
    dashboardViewElement = new DivElement()..classes.add('dashboard');
    _projectActionsContainer = new DivElement()
      ..classes.add('dashboard__project-actions');
    _conversationsLink = new AnchorElement()
      ..classes.add('dashboard__project-actions-link')
      ..text = "Go to conversations"
      ..href = "#";
    _oversightDashboardLink = new AnchorElement()
      ..classes.add('dashboard__project-actions-link')
      ..text = "Go to oversight dashboard"
      ..href = "#";
    activePackagesContainer = new DivElement()
      ..classes.add('active-packages');
    availablePackagesContainer = new DivElement()
      ..classes.add('available-packages');

    _projectActionsContainer.append(_conversationsLink);
    _projectActionsContainer.append(_oversightDashboardLink);
    dashboardViewElement.append(_projectActionsContainer);
    dashboardViewElement.append(activePackagesContainer);
    dashboardViewElement.append(availablePackagesContainer);
  }

  void renderActivePackages() {
    activePackagesContainer.children.clear();
    activePackagesContainer.append(new HeadingElement.h1()..text = "Active packages");
    if (activePackages.isNotEmpty) {
      activePackages.forEach((package) => activePackagesContainer.append(package.packageElement));
    }
  }

  void renderAvailablePackages() {
    availablePackagesContainer.children.clear();
    availablePackagesContainer.append(new HeadingElement.h1()..text = "Add a package");
    if (activePackages.isNotEmpty) {
      availablepackages.forEach((package) => availablePackagesContainer.append(package.packageElement));
    }
  }
}

class ActivePackagesViewPartial {
  DivElement packageElement;
  HeadingElement _packageName;
  DivElement _packageActionsContainer;
  AnchorElement _dashboardAction;
  AnchorElement _conversationsAction;
  AnchorElement _configureAction;

  ActivePackagesViewPartial(String packageName) {
    packageElement = new DivElement()
      ..classes.add('active-packages__package');
    _packageName = new HeadingElement.h4()
      ..text = '$packageName (Active)';
    _packageActionsContainer = new DivElement()
      ..classes.add('active-packages__package-actions');
    _dashboardAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Dashboard'
      ..href = '#/dashboard';
    _conversationsAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Conversations'
      ..href = '#/conversations';
    _configureAction = new AnchorElement()
      ..classes.add('active-packages__package-action')
      ..text = 'Configure'
      ..href = '#/configuration';
    _packageActionsContainer.append(_dashboardAction);
    _packageActionsContainer.append(_conversationsAction);
    _packageActionsContainer.append(_configureAction);
    packageElement.append(_packageName);
    packageElement.append(_packageActionsContainer);
  }
}

class AvailablePackagesViewPartial {
  DivElement packageElement;
  DivElement _addPackageLinkContainer;
  AnchorElement _addPackageLink;
  DivElement _descriptionContaner;
  HeadingElement _descriptionTitle;
  DivElement _descriptionDetails;

  AvailablePackagesViewPartial(String packageName, String descriptionTitle, List<String> descriptionDetails) {
    packageElement = new DivElement()
      ..classes.add('available-packages__package');
    _addPackageLinkContainer = new DivElement()
      ..classes.add('available-packages__add-package');
    _addPackageLink = new AnchorElement()
      ..classes.add('available-packages__add-package-link')
      ..text = packageName
      ..href = '#';
    _descriptionContaner = new DivElement()
      ..classes.add('available-packages__package-description');
    _descriptionTitle = new HeadingElement.h4()
      ..text = descriptionTitle;
    _descriptionDetails = new DivElement();
    descriptionDetails.forEach((detail) => _descriptionDetails.append(new ParagraphElement()..text = detail));

    _addPackageLinkContainer.append(_addPackageLink);
    _descriptionContaner.append(_descriptionTitle);
    _descriptionContaner.append(_descriptionDetails);
    packageElement.append(_addPackageLinkContainer);
    packageElement.append(_descriptionContaner);
  }
}

class ConfigurationView {
  DivElement configurationViewElement;
  DivElement _tagsContainer;
  ConfigurationViewTagListPartial tagList;
  ConfigurationViewTagResponsesPartial tagResponses;

  ConfigurationView() {
    configurationViewElement = new DivElement()
      ..classes.add('configure-package');
    _tagsContainer = new DivElement()
      ..classes.add('configure-package__tags');
    tagList = new ConfigurationViewTagListPartial();
    tagResponses = new ConfigurationViewTagResponsesPartial();

    _tagsContainer.append(tagList.tagListElement);
    _tagsContainer.append(tagResponses.tagResponsesElement);
    configurationViewElement.append(HeadingElement.h1()
      ..classes.add('configure-package__title')
      ..text = "Configure Package");
    configurationViewElement.append(_tagsContainer);
  }
}

class ConfigurationViewTagListPartial {
  Element tagListElement;

  ConfigurationViewTagListPartial() {
    tagListElement = new Element.ul()
      ..classes.add('tags-list');
  }

  void renderTagList(Map<String, bool> tags) {
    tagListElement.children.clear();
    tags.forEach((tag, state) {
      var tagItem = new Element.li()
        ..classes.add('tag-list__tag-item')
        ..text = tag;
      tagItem.onClick.listen((event) {
        var selectedTag = (event.target as Element);
        controller.command(controller.UIAction.configurationTagSelected, new controller.ConfigurationTagData(selectedTag: selectedTag.text.trim()));
      });
      tagItem.onDragOver.listen((event) => event.preventDefault());
      tagItem.onDragEnter.listen((event) {
        event.preventDefault();
        (event.target as Element).classes.add('tag-list__tag-item-drop-target');
      });
      tagItem.onDragLeave.listen((event) => (event.target as Element).classes.remove('tag-list__tag-item-drop-target'));
      tagItem.onDrop.listen((event) {
        event.preventDefault();
        var dropTarget = (event.target as Element);
        dropTarget.classes.remove('tag-list__tag-item-drop-target');
        if (dropTarget.classes.contains('tag-list__tag-item')) {
          var responseData = jsonDecode(event.dataTransfer.getData("Text"));
          responseData.forEach((language, text) {
            controller.command(controller.UIAction.addConfigurationResponseEntries,
              new controller.ConfigurationResponseData(parentTag: dropTarget.text, language: language, text: text));
          });
        }
      });
      tagListElement.append(tagItem);
    });
    toggleTagsSelectedState(tags);
    tagListElement.append(
      new ButtonElement()
        ..classes.add('tag-list__add-tag-action')
        ..text = '+'
        ..onClick.listen((event) => tagListElement.append(addTagDropDown(controller.additionalConfigurationTags.toList())))
    );
  }

  DivElement addTagDropDown(List<String> tags) {
    var addTagModal = new DivElement()
      ..classes.add('tag-responses__add-tag-modal');
    addTagModal.append(
      HeadingElement.h6()
        ..classes.add('tag-responses__add-tag-modal-heading')
        ..text = 'Select new tag to add');
    addTagModal.append(
      new ButtonElement()
        ..classes.add('tag-responses__add-tag-modal-close-button')
        ..text = 'x'
        ..onClick.listen((_) => addTagModal.remove()));
    var tagOptions = new SelectElement()
      ..classes.add('tag-responses__add-tag-modal-dropdown')
      ..onChange.listen((event) {
        var selectedOption = (event.currentTarget as SelectElement).value;
        controller.command(controller.UIAction.addConfigurationTag, new controller.ConfigurationTagData(tagToAdd: selectedOption));
        if(tagListElement.children.last is DivElement) tagListElement.children.removeLast();
      });
    tagOptions.add(new OptionElement()..text = '-', false);
    tags.forEach((tag) {
      var option = new OptionElement()
        ..text = tag
        ..value = tag;
      tagOptions.add(option, false);
    });
    addTagModal.append(tagOptions);
    return addTagModal;
  }

  void toggleTagsSelectedState(Map<String, bool> tags) {
    tagListElement.children.forEach((tag) {
      tag.classes.toggle('tag-list__tag-item_active', tags[tag.text]);
    });
  }
}

class ConfigurationViewTagResponsesPartial {
  DivElement tagResponsesElement;
  DivElement _tagResponsesHeader;
  DivElement _tagResponsesBody;

  ConfigurationViewTagResponsesPartial() {
    tagResponsesElement = new DivElement()
      ..classes.add('tag-responses');
    _tagResponsesHeader = new DivElement()
      ..classes.add('tag-responses__header');
    _tagResponsesBody = new DivElement()
      ..classes.add('tag-responses__content');
  }

  void renderResponses(String tag, List<String> responseLanguages, List<List<String>> responses) {
    tagResponsesElement.children.clear();
    _tagResponsesHeader.children.clear();
    _tagResponsesBody.children.clear();
    responseLanguages.forEach((lang) => _tagResponsesHeader.append(
      new HeadingElement.h5()
        ..classes.add('tag-responses__header-title')
        ..text = lang
    ));
    for (int i = 0; i < responses.length; i++) {
      var item = new DivElement()
          ..classes.add('tag-responses__item-row')
          ..append(
            new DivElement()
            ..draggable = true
            ..classes.add('tag-responses__item-drag-handle')
            ..onDragStart.listen((event) {
              var handle = event.target as Element;
              var parent = handle.parent;
              handle.classes.add('tag-responses__item-drag-handle_dragging');
              var payload = {};
              parent.children.skip(1).forEach((el) => payload[el.attributes['language']] = el.text);
              event.dataTransfer.setData("Text", jsonEncode(payload));
            })
            ..onDragEnd.listen((event) => (event.target as Element).classes.remove('tag-responses__item-drag-handle_dragging'))
          );
      for (int j = 0; j < responses[i].length; j++) {
        item.append(
            new ParagraphElement()
              ..classes.add('tag-responses__item')
              ..attributes.addAll({'contenteditable': 'true', 'parent-tag': tag, 'language': responseLanguages[j] ,'index': '$i'})
              ..text = responses[i][j]
              ..draggable = true
              ..onBlur.listen((event) {
                var reponseElement = (event.currentTarget as Element);
                var parentTag = reponseElement.attributes['parent-tag'];
                var index = int.parse(reponseElement.attributes['index']);
                var language = reponseElement.attributes['language'];
                var text = reponseElement.text;
                controller.command(controller.UIAction.editConfigurationTagResponse, new controller.ConfigurationResponseData(parentTag: parentTag, index: index, language: language, text: text));
          }));
        _tagResponsesBody.append(item);
      }
    }
    tagResponsesElement.append(_tagResponsesHeader);
    tagResponsesElement.append(_tagResponsesBody);
    tagResponsesElement.append(
      new ButtonElement()
          ..classes.add('tag-responses__add-responses-action')
          ..text = '+'
          ..onClick.listen((event) {
            controller.command(controller.UIAction.addConfigurationResponseEntries, new controller.ConfigurationResponseData(parentTag: tag));
            window.scrollTo(0, mainElement.scrollHeight);
          })
    );
  }
}
