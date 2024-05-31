class Validator {
  // Regex pattern for validating an email
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  // Method to validate an email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email cannot be empty';
    } else if (!_emailRegExp.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Method to validate a password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    // else if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
    //   return 'Password must contain at least one uppercase letter';
    // } else if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
    //   return 'Password must contain at least one lowercase letter';
    // } else if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
    //   return 'Password must contain at least one number';
    // } else if (!RegExp(r'(?=.*[\W_])').hasMatch(password)) {
    //   return 'Password must contain at least one special character';
    // }
    return null;
  }

  static String? validatePasswordsMatch(String? password,String? confirmPassword) {
    if (password == null || confirmPassword == null) {
      return "Passwords cannot be null";
    }
    else if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null; // if passwords match, return null
  }

}

