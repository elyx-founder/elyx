import '../models/mentor_model.dart';

class MentorEngine {

  static late MentorModel currentMentor;

  static int level = 1;

  static void setMentor(MentorModel mentor) {
    currentMentor = mentor;
  }

  static void increaseLevel() {
    level++;
  }

  static String getMentorName() {
    return currentMentor.name;
  }

}
