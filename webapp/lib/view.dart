import 'dart:html';

import 'logger.dart';
import 'controller.dart' as controller;

Logger log = new Logger('view.dart');

Element get headerElement => querySelector('header');
Element get mainElement => querySelector('main');
Element get footerElement => querySelector('footer');

NavView navView;

void init() {
  navView = NavView();
  headerElement.append(navView.navElement);
}

class NavView {
DivElement navElement;
DivElement appLogos;
DivElement projectTitle;

  NavView() {
    navElement = new DivElement()
      ..classes.add('nav');
    appLogos = new DivElement()
      ..classes.add('nav__app-logo');
    projectTitle = new DivElement()
      ..classes.add('nav__project-title')
      ..append(new SpanElement()..text = 'COVID IMAQAL Batch replies (Week 12)');

    appLogos.append(new ImageElement(src: 'assets/africas-voices-logo.svg'));

    navElement.append(appLogos);
    navElement.append(projectTitle);
  }
}

class ContentView {
  DivElement contentElement;

  ContentView() {
    contentElement = new DivElement();
  }
}
