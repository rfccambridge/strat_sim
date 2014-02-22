
abstract class Behavior {  
  // declare any variables you need between steps here

  // true means goal is on right
  Behavior(Boolean side) {
  }
  
  abstract void reset(String msg);

  abstract CmdSet update(Team myTeam, Team otherTeam, Ball ball);
}
