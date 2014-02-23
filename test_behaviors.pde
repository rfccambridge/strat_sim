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
  
  Boolean side, wall;
  float fieldWidth, fieldHeight, goalTop, goalBottom;
  PVector goalMid, otherGoalMid;
  
  public BehaveBlockDefense(Boolean side_, Boolean wall_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_);
    this.side = side_;
    this.fieldWidth = fieldWidth_;
    this.fieldHeight = fieldHeight_;
    this.goalTop = goalTop_;
    this.goalBottom = goalBottom_;
    this.wall = wall_;
    goalMid = new PVector(this.side ? fieldWidth : 0, (goalTop + goalBottom) / 2);
    otherGoalMid = new PVector(this.side ? 0 : fieldWidth, (goalTop + goalBottom) / 2);
  }
  
  public void reset(String msg) {
  }
  
  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    // Calculate vector between ball and goal
    PVector v = PVector.sub(goalMid, ball.position);
    float ballToGoal = v.mag();
    v.limit(ballToGoal / 2);
    
    // Non goalie robots
    for (int i=1; i<n; i++) {
      // set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
      PVector newPos = PVector.add(ball.position, v);
      // can't be in goalie area
      if (this.side && newPos.x > ((7.0/8)*this.fieldWidth)) {
        newPos.x = (7.0/8)*this.fieldWidth;
      } else if (!this.side && newPos.x < ((1.0/8)*this.fieldWidth)) {
        newPos.x = (1.0/8)*this.fieldWidth;
      }
      if (this.wall) {
        newPos.y += (i-(n-1)/2.0) * 2 * 10;
      }
      cmds.targets[i] = newPos;
      cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
    }
    
    // Goalie robot
    v.limit(ballToGoal / 8);
    cmds.targets[0] = PVector.sub(goalMid, v);
    cmds.kicks[0] = PVector.sub(otherGoalMid, myTeam.positions[0]);
    return cmds;
  }
}

class BehavePointDefense extends BehaveBlockDefense {
  public BehavePointDefense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_, false, fieldWidth_, fieldHeight_, goalTop_, goalBottom_);
  }
}

class BehaveWallDefense extends BehaveBlockDefense {
  public BehaveWallDefense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_, true, fieldWidth_, fieldHeight_, goalTop_, goalBottom_);
  }
}
