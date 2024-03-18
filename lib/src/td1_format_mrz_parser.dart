part of 'mrz_parser.dart';

class _TD1MRZFormatParser {
  _TD1MRZFormatParser._();

  static const _linesLength = 30;
  static const _linesCount = 3;

  static bool isValidInput(final List<String> input) =>
      input.length == _linesCount &&
      input.every((final s) => s.length == _linesLength);

  static MRZResult parse(final List<String> input, final bool validate) {
    if (!isValidInput(input)) {
      throw const InvalidMRZInputException();
    }

    final firstLine = input[0];
    final secondLine = input[1];
    final thirdLine = input[2];

    final documentTypeRaw = firstLine.substring(0, 2);
    final countryCodeRaw = firstLine.substring(2, 5);
    final documentNumberRaw = firstLine.substring(5, 14);
    final documentNumberCheckDigitRaw = firstLine[14];
    final optionalDataRaw = firstLine.substring(15, 30);
    final birthDateRaw = secondLine.substring(0, 6);
    final birthDateCheckDigitRaw = secondLine[6];
    final sexRaw = secondLine.substring(7, 8);
    final expiryDateRaw = secondLine.substring(8, 14);
    final expiryDateCheckDigitRaw = secondLine[14];
    final nationalityRaw = secondLine.substring(15, 18);
    final optionalData2Raw = secondLine.substring(18, 29);
    final finalCheckDigitRaw = secondLine[29];
    final namesRaw = thirdLine.substring(0, 30);

    final documentTypeFixed =
        MRZFieldRecognitionDefectsFixer.fixDocumentType(documentTypeRaw);
    final countryCodeFixed =
        MRZFieldRecognitionDefectsFixer.fixCountryCode(countryCodeRaw);
    final documentNumberFixed = documentNumberRaw;
    final documentNumberCheckDigitFixed =
        MRZFieldRecognitionDefectsFixer.fixCheckDigit(
            documentNumberCheckDigitRaw);
    final optionalDataFixed = optionalDataRaw;
    final birthDateFixed =
        MRZFieldRecognitionDefectsFixer.fixDate(birthDateRaw);
    final birthDateCheckDigitFixed =
        MRZFieldRecognitionDefectsFixer.fixCheckDigit(birthDateCheckDigitRaw);
    final sexFixed = MRZFieldRecognitionDefectsFixer.fixSex(sexRaw);
    final expiryDateFixed =
        MRZFieldRecognitionDefectsFixer.fixDate(expiryDateRaw);
    final expiryDateCheckDigitFixed =
        MRZFieldRecognitionDefectsFixer.fixCheckDigit(expiryDateCheckDigitRaw);
    final nationalityFixed =
        MRZFieldRecognitionDefectsFixer.fixNationality(nationalityRaw);
    final optionalData2Fixed = optionalData2Raw;
    final finalCheckDigitFixed =
        MRZFieldRecognitionDefectsFixer.fixCheckDigit(finalCheckDigitRaw);
    final namesFixed = MRZFieldRecognitionDefectsFixer.fixNames(namesRaw);
    String? optionalData,
        optionalData2,
        documentType,
        countryCode,
        documentNumber,
        nationality = '';
    List<String>? names;
    DateTime? birthDate, expiryDate;
    Sex? sex;
    final documentNumberIsValid = int.tryParse(documentNumberCheckDigitFixed) ==
        MRZCheckDigitCalculator.getCheckDigit(documentNumberFixed);

    if (documentNumberIsValid) {
      documentType = MRZFieldParser.parseDocumentType(documentTypeFixed);
    } else if (validate) {
      throw const InvalidDocumentNumberException();
    }

    final birthDateIsValid = int.tryParse(birthDateCheckDigitFixed) ==
        MRZCheckDigitCalculator.getCheckDigit(birthDateFixed);

    if (birthDateIsValid) {
      birthDate = MRZFieldParser.parseBirthDate(birthDateFixed);
    } else if (validate) {
      throw const InvalidBirthDateException();
    }

    final expiryDateIsValid = int.tryParse(expiryDateCheckDigitFixed) ==
        MRZCheckDigitCalculator.getCheckDigit(expiryDateFixed);

    if (expiryDateIsValid) {
      expiryDate = MRZFieldParser.parseExpiryDate(expiryDateFixed);
    } else if (validate) {
      throw const InvalidExpiryDateException();
    }

    final finalCheckStringFixed =
        '$documentNumberFixed$documentNumberCheckDigitFixed'
        '$optionalDataFixed'
        '$birthDateFixed$birthDateCheckDigitFixed'
        '$expiryDateFixed$expiryDateCheckDigitFixed'
        '$optionalData2Fixed';
    final finalCheckStringIsValid = int.tryParse(finalCheckDigitFixed) ==
        MRZCheckDigitCalculator.getCheckDigit(finalCheckStringFixed);

    if (!finalCheckStringIsValid && validate) {
      throw const InvalidMRZValueException();
    }

    countryCode = MRZFieldParser.parseCountryCode(countryCodeFixed);
    documentNumber = MRZFieldParser.parseDocumentNumber(documentNumberFixed);
    optionalData = MRZFieldParser.parseOptionalData(optionalDataFixed);

    sex = MRZFieldParser.parseSex(sexFixed);

    nationality = MRZFieldParser.parseNationality(nationalityFixed);
    optionalData2 = MRZFieldParser.parseOptionalData(optionalData2Fixed);
    names = MRZFieldParser.parseNames(namesFixed);

    return MRZResult(
      documentType: documentType,
      countryCode: countryCode,
      surnames: names[0],
      givenNames: names[1],
      documentNumber: documentNumber,
      nationalityCountryCode: nationality,
      birthDate: birthDate,
      sex: sex,
      expiryDate: expiryDate,
      personalNumber: optionalData,
      personalNumber2: optionalData2,
    );
  }
}
