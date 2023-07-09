class Progress {
  int currentProgress;
  int maximum;
  Progress({this.currentProgress = 0, this.maximum = 0});

  void progress() {
    currentProgress++;
  }

  double getProgressPercentage() {
    return currentProgress/maximum;
  }
}
