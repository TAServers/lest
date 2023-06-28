import { classList, functionsList, matcherFunctions } from "./json-docs";
import AnnotationBuilder from "./annotationBuilder";

const document = new AnnotationBuilder();

classList.forEach((classDef) => {
	document.startClass(classDef.name, classDef.description);
	classDef.fields?.forEach((field) => document.addField(field));
	document.addClassDeclaration();
	classDef.methods?.forEach((method) => document.addFunction(method));
	document.endClass();
});

functionsList.forEach((func) => {
	document.addFunction(func);
});

document.startClass("lest.Matchers", "Matchers for expect()", true);
document.addClassDeclaration();
matcherFunctions.forEach((func) => document.addFunction(func));
document.endClass();

console.log(document.build());
