class BehaveFollow extends Behavior {

  // true means goal is on right
  public BehaveFollow(Boolean side) {
    super(side);
  }
  
  public void reset(String msg) {
  }

  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    for (int i=0; i<n; i++) {
      cmds.targets[i] = new PVector(mouseX,mouseY);
      if (mousePressed) {
        cmds.kicks[i] = PVector.sub(ball.position, myTeam.positions[i]);
      }
    }
    return cmds;
  }
}

class BehaveBlockDefense extends Behavior {
  
  Boolean side;
  float fieldWidth, fieldHeight, goalTop, goalBottom;
  PVector goalMid, otherGoalMid;
  
  public BehaveBlockDefense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_);
    this.side = side_;
    this.fieldWidth = fieldWidth_;
    this.fieldHeight = fieldHeight_;
    this.goalTop = goalTop_;
    this.goalBottom = goalBottom_;
    goalMid = new PVector(this.side ? fieldWidth : 0, (goalTop + goalBottom) / 2);
    otherGoalMid = new PVector(this.side ? 0 : fieldWidth, (goalTop + goalBottom) / 2);
  }
  
  public void reset(String msg) {
  }
  
  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    for (int i=0; i<n; i++) {
      // set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
      PVector v = PVector.sub(goalMid, ball.position);
      float ballToGoal = v.mag();
      v.limit(ballToGoal / 2);
      cmds.targets[i] = PVector.add(ball.position, v);
      cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
    }
    return cmds;
  }
}
