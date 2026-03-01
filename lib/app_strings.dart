class AppStrings {
  static String _languageCode = 'he';

  static void setLanguage(String code) {
    _languageCode = code;
  }

  static String get(String key) {
    if (_languageCode == 'he') {
      return _hebrew[key] ?? key;
    } else {
      return _english[key] ?? key;
    }
  }

  // Keys
  static const String appTitleKey = 'appTitle';
  static const String dailyGoalLabelKey = 'dailyGoalLabel';
  static const String unlockRewardTitleKey = 'unlockRewardTitle';
  static const String stepsLabelKey = 'stepsLabel';
  static const String progressTitleKey = 'progressTitle';
  static const String goalAchievedMessageKey = 'goalAchievedMessage';
  static const String stepsRemainingPrefixKey = 'stepsRemainingPrefix';
  static const String stepsRemainingSuffixKey = 'stepsRemainingSuffix';
  static const String setGoalTitleKey = 'setGoalTitle';
  static const String goalInputLabelKey = 'goalInputLabel';
  static const String cancelBtnKey = 'cancelBtn';
  static const String saveBtnKey = 'saveBtn';
  static const String changeGoalMenuKey = 'changeGoalMenu';
  static const String customRewardMenuKey = 'customRewardMenu';
  static const String debugModeLabelKey = 'debugModeLabel';
  static const String permissionDeniedKey = 'permissionDenied';
  static const String passwordDialogTitleKey = 'passwordDialogTitle';
  static const String passwordInputLabelKey = 'passwordInputLabel';
  static const String passwordErrorKey = 'passwordError';
  static const String submitBtnKey = 'submitBtn';
  static const String pedometerErrorPrefixKey = 'pedometerErrorPrefix';

  // Getters
  static String get appTitle => get(appTitleKey);
  static String get dailyGoalLabel => get(dailyGoalLabelKey);
  static String get unlockRewardTitle => get(unlockRewardTitleKey);
  static String get stepsLabel => get(stepsLabelKey);
  static String get progressTitle => get(progressTitleKey);
  static String get goalAchievedMessage => get(goalAchievedMessageKey);
  static String stepsRemainingMessage(int remaining) => 
      _languageCode == 'he' 
          ? '${get(stepsRemainingPrefixKey)} $remaining ${get(stepsRemainingSuffixKey)}'
          : '${get(stepsRemainingPrefixKey)} $remaining ${get(stepsRemainingSuffixKey)}'; // Simplification for now, exact grammar might vary

  static String get setGoalTitle => get(setGoalTitleKey);
  static String get goalInputLabel => get(goalInputLabelKey);
  static String get cancelBtn => get(cancelBtnKey);
  static String get saveBtn => get(saveBtnKey);
  static String get changeGoalMenu => get(changeGoalMenuKey);
  static String get customRewardMenu => get(customRewardMenuKey);
  static String get debugModeLabel => get(debugModeLabelKey);
  static String get permissionDenied => get(permissionDeniedKey);
  static String pedometerError(dynamic error) => '${get(pedometerErrorPrefixKey)}: $error';

  static String get passwordDialogTitle => get(passwordDialogTitleKey);
  static String get passwordInputLabel => get(passwordInputLabelKey);
  static String get passwordError => get(passwordErrorKey);
  static String get submitBtn => get(submitBtnKey);

  static const String defaultRewardImageUrl = 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&q=80&w=1000';

  static const Map<String, String> _english = {
    appTitleKey: 'Step Goal Reward',
    dailyGoalLabelKey: 'Weekly Goal: ',
    unlockRewardTitleKey: 'Unlock Your Reward',
    stepsLabelKey: 'Steps',
    progressTitleKey: 'Your Progress',
    goalAchievedMessageKey: 'Goal Achieved! Enjoy the view.',
    stepsRemainingPrefixKey: 'Walk',
    stepsRemainingSuffixKey: 'more steps to reveal',
    setGoalTitleKey: 'Set Step Goal',
    goalInputLabelKey: 'Goal (e.g. 10000)',
    cancelBtnKey: 'Cancel',
    saveBtnKey: 'Save',
    changeGoalMenuKey: 'Change Goal',
    customRewardMenuKey: 'Custom Reward',
    debugModeLabelKey: 'Debug Mode',
    permissionDeniedKey: 'Permission denied',
    pedometerErrorPrefixKey: 'Pedometer Error',
    passwordDialogTitleKey: 'Settings Protection',
    passwordInputLabelKey: 'Enter Password',
    passwordErrorKey: 'Incorrect password!',
    submitBtnKey: 'Submit',
  };

  static const Map<String, String> _hebrew = {
    appTitleKey: 'פרס יעד צעדים',
    dailyGoalLabelKey: 'יעד שבועי: ',
    unlockRewardTitleKey: 'פתח את הפרס שלך',
    stepsLabelKey: 'צעדים',
    progressTitleKey: 'ההתקדמות שלך',
    goalAchievedMessageKey: 'היעד הושג! תהנה מהנוף.',
    stepsRemainingPrefixKey: 'לך עוד',
    stepsRemainingSuffixKey: 'צעדים כדי לגלות',
    setGoalTitleKey: 'הגדר יעד צעדים',
    goalInputLabelKey: 'יעד (לדוגמה 10000)',
    cancelBtnKey: 'ביטול',
    saveBtnKey: 'שמור',
    changeGoalMenuKey: 'שנה יעד',
    customRewardMenuKey: 'פרס מותאם אישית',
    debugModeLabelKey: 'מצב פיתוח',
    permissionDeniedKey: 'ההרשאה נדחתה',
    pedometerErrorPrefixKey: 'שגיאת מד צעדים',
    passwordDialogTitleKey: 'הגנת הגדרות',
    passwordInputLabelKey: 'הזן סיסמה',
    passwordErrorKey: 'סיסמה שגויה!',
    submitBtnKey: 'אישור',
  };
}
