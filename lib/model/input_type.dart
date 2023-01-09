enum InputType { date, text, check, chassi, number }

InputType inputTypeFor(String inputTypeString) {
  switch (inputTypeString) {
    case "mes/ano":
      return InputType.date;
    case "text":
      return InputType.text;
    case "check":
      return InputType.check;
    case "chassi":
      return InputType.chassi;
    case "number":
      return InputType.number;
    default:
      return null;
  }
}

String nameFor(InputType inputType) {
  switch (inputType) {
    case InputType.date:
      return "mes/ano";
      break;
    case InputType.text:
      return "text";
      break;
    case InputType.check:
      return "check";
      break;
    case InputType.chassi:
      return "chassi";
      break;
    case InputType.number:
      return "number";
      break;
    default:
      return null;
  }
}
