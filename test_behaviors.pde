int robotRadius = 10;

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
        newPos.y += (i-(n-1)/2.0) * 2 * robotRadius; // stagger robots in vertical wall
      }
      cmds.targets[i] = newPos;
      cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
    }
    
    // Goalie robot
    PVector goaliePos = ball.position.get();
    if (this.side && goaliePos.x < (7.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (7.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    } else if (!this.side && goaliePos.x > (1.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (1.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    }
    cmds.targets[0] = goaliePos;
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

class BehaveSimplePassOffense extends Behavior {
  
  Boolean side;
  float fieldWidth, fieldHeight, goalTop, goalBottom, goalWidth;
  PVector goalMid, otherGoalMid;
  
  public BehaveSimplePassOffense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_);
    this.side = side_;
    this.fieldWidth = fieldWidth_;
    this.fieldHeight = fieldHeight_;
    this.goalTop = goalTop_;
    this.goalBottom = goalBottom_;
    this.goalWidth = abs(goalBottom - goalTop);
    this.goalMid = new PVector(this.side ? fieldWidth : 0, (goalTop + goalBottom) / 2);
    this.otherGoalMid = new PVector(this.side ? 0 : fieldWidth, (goalTop + goalBottom) / 2);
  }
  
  public void reset(String msg) {
  }
  
  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    // let robot 0 be goalie, robot 1 a dribbler controlling the ball, other n-2 robots be in shooting range
    // n-2 robots get into shooting range
    int maxRobot = 2;
    float maxOfOpenings = 0;
    for (int i=1; i<n; i++) {
      // set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
      PVector homeBase = new PVector(this.side ? (1.0/8)*this.fieldWidth+10*robotRadius : (7.0/8)*this.fieldWidth-10*robotRadius, ((i-1)*1.0/(n-1))*fieldHeight);
      PVector toBall = PVector.sub(ball.position, myTeam.positions[i]);
      toBall.limit(10*robotRadius);
      cmds.targets[i] = PVector.add(homeBase, toBall);
      // determine kick direction by most open angle section
      int numCandidates = 4;
      PVector vecToGoal = PVector.sub(PVector.add(otherGoalMid, new PVector(0, -this.goalWidth/2.0+30)), myTeam.positions[i]);
      PVector vecToGoalBottom = PVector.sub(PVector.add(otherGoalMid, new PVector(0, this.goalWidth/2.0-30)), myTeam.positions[i]);
      float angleOpening = abs(PVector.angleBetween(vecToGoalBottom, vecToGoal));
      float maxOpening = 0;
      int maxCandidate = 0;
      for (int j=0; j<=numCandidates; j++) {
        // calculate distance between shot trajectory and closest robot
        float minRobotToTrajectory = abs(PVector.dot(new PVector(vecToGoal.y, -vecToGoal.x), otherTeam.positions[0])) / vecToGoal.mag();
        int minRobot = 0;
        for (int k=1; k<otherTeam.n; k++) {
          float robotToTrajectory = abs(PVector.dot(new PVector(vecToGoal.y, -vecToGoal.x), otherTeam.positions[k])) / vecToGoal.mag();
          if (robotToTrajectory < minRobotToTrajectory) {
            minRobotToTrajectory = robotToTrajectory;
            minRobot = k;
          } 
        }
        if (minRobotToTrajectory > maxOpening) {
          maxOpening = minRobotToTrajectory;
          maxCandidate = j;
        }
        vecToGoal.rotate(angleOpening / (numCandidates - 1));
      }
      vecToGoalBottom.rotate(-(numCandidates-maxCandidate-1)*angleOpening / (numCandidates - 1));
      cmds.kicks[i] = vecToGoalBottom;
      if (maxOpening > maxOfOpenings) {
        maxOfOpenings = maxOpening;
        maxRobot = i;
      }
    }
    
    // first navigate to the ball as long as you're not touching the ball
//    PVector dribblerToBall = PVector.sub(myTeam.positions[1], ball.position);
//    if (dribblerToBall.mag() <= 14) { // touching the ball
      cmds.targets[1] = ball.position.get();
//    } else {
//      PVector ballToGoal = PVector.sub(otherGoalMid, ball.position);
//      ballToGoal.limit(5);
//      cmds.targets[1] = PVector.sub(ball.position, ballToGoal);
//    }
    if (this.side && cmds.targets[1].x < (1.0/8)*this.fieldWidth) {
      cmds.targets[1].x = (1.0/8)*this.fieldWidth;
    } else if (!this.side && cmds.targets[1].x > (7.0/8)*this.fieldWidth) {
      cmds.targets[1].x = (7.0/8)*this.fieldWidth;
    }
    cmds.kicks[1] = PVector.sub(myTeam.positions[maxRobot], myTeam.positions[1]);
    //cmds.kicks[1] = PVector.sub(otherGoalMid, myTeam.positions[1]);

    // goalie
    PVector v = PVector.sub(goalMid, ball.position);
    PVector goaliePos = ball.position.get();
    if (this.side && goaliePos.x < (7.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (7.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    } else if (!this.side && goaliePos.x > (1.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (1.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    }
    cmds.targets[0] = goaliePos;
    cmds.kicks[0] = PVector.sub(myTeam.positions[maxRobot], myTeam.positions[0]);
    
    return cmds;
  }
}

class BehaveSurroundOffense extends Behavior {
  
  Boolean side;
  float fieldWidth, fieldHeight, goalTop, goalBottom, goalWidth;
  PVector goalMid, otherGoalMid;
  
  public BehaveSurroundOffense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_);
    this.side = side_;
    this.fieldWidth = fieldWidth_;
    this.fieldHeight = fieldHeight_;
    this.goalTop = goalTop_;
    this.goalBottom = goalBottom_;
    this.goalWidth = abs(goalBottom - goalTop);
    this.goalMid = new PVector(this.side ? fieldWidth : 0, (goalTop + goalBottom) / 2);
    this.otherGoalMid = new PVector(this.side ? 0 : fieldWidth, (goalTop + goalBottom) / 2);
  }
  
  public void reset(String msg) {
  }
  
  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    // let robot 0 be goalie, robot 1 a dribbler controlling the ball, other n-2 robots be in shooting range
    // n-2 robots get into shooting range
    int maxRobot = 2;
    float maxOfOpenings = 0;
    PVector secClosestPos = null;
    PVector closestPos = null;
    /*    for (int i=0; i<otherTeam.n; i++) {
      PVector pos = otherTeam.positions[i];
      // assuming side=false (ie, they are defending right side) 
      if (pos.x > closestPos.x) {
	secClosestPos = closestPos;
	closestPos = pos;
      } else if (pos.x > secClosestPos.x) {
	secClosestPos = pos;
      }
    }*/
    for (int i=1; i<n; i++) {
      float edgeRat = 1.0 / 64.0;
      float midRat = 1.0 / 128.0;
      float farRat = 1.0 / 16.0;
      float edgeBackDist = fieldWidth * 1.0 / 16.0;
      float midBackDist =  fieldWidth * 1.0 / 32.0;
      PVector homeBase;
      if (i == 2) {
	float botPY = this.fieldHeight / 4.0;
        homeBase = new PVector(this.side ? (edgeRat)*this.fieldWidth+10*robotRadius : (1.0-edgeRat)*this.fieldWidth-10*robotRadius, botPY);
      } else if (i == 3) {
	float topPY = 3.0 * this.fieldHeight / 4.0;
        homeBase = new PVector(this.side ? (edgeRat)*this.fieldWidth+10*robotRadius : (1.0-edgeRat)*this.fieldWidth-10*robotRadius, topPY);
      } else if (i == 4) {
	float midPY = this.fieldHeight / 2.0;
	//        homeBase = new PVector(this.side ? (midRat)*this.fieldWidth+10*robotRadius : max((1.0-midRat)*this.fieldWidth-10*robotRadius, midBackDist), midPY);
	homeBase = new PVector(this.side ? (midRat)*this.fieldWidth+10*robotRadius : (1.0-midRat)*this.fieldWidth-10*robotRadius, midPY);
      } else if (i == 5) {
	float farPY = this.fieldHeight / 2.0;
        homeBase = new PVector(this.side ? (farRat)*this.fieldWidth+10*robotRadius : (1.0-farRat)*this.fieldWidth-10*robotRadius, farPY);
      } else {
	// set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
	homeBase = new PVector(this.side ? (1.0/8)*this.fieldWidth+10*robotRadius : (7.0/8)*this.fieldWidth-10*robotRadius, ((i-1)*1.0/(n-1))*fieldHeight);
      }
      PVector toBall = PVector.sub(ball.position, myTeam.positions[i]);
      toBall.limit(10*robotRadius);
      cmds.targets[i] = PVector.add(homeBase, toBall);
      // determine kick direction by most open angle section
      int numCandidates = 4;
      PVector vecToGoal = PVector.sub(PVector.add(otherGoalMid, new PVector(0, -this.goalWidth/2.0+30)), myTeam.positions[i]);
      PVector vecToGoalBottom = PVector.sub(PVector.add(otherGoalMid, new PVector(0, this.goalWidth/2.0-30)), myTeam.positions[i]);
      float angleOpening = abs(PVector.angleBetween(vecToGoalBottom, vecToGoal));
      float maxOpening = 0;
      int maxCandidate = 0;
      for (int j=0; j<=numCandidates; j++) {
        // calculate distance between shot trajectory and closest robot
        float minRobotToTrajectory = abs(PVector.dot(new PVector(vecToGoal.y, -vecToGoal.x), otherTeam.positions[0])) / vecToGoal.mag();
        int minRobot = 0;
        for (int k=1; k<otherTeam.n; k++) {
          float robotToTrajectory = abs(PVector.dot(new PVector(vecToGoal.y, -vecToGoal.x), otherTeam.positions[k])) / vecToGoal.mag();
          if (robotToTrajectory < minRobotToTrajectory) {
            minRobotToTrajectory = robotToTrajectory;
            minRobot = k;
          } 
        }
        if (minRobotToTrajectory > maxOpening) {
          maxOpening = minRobotToTrajectory;
          maxCandidate = j;
        }
        vecToGoal.rotate(angleOpening / (numCandidates - 1));
      }
      vecToGoalBottom.rotate(-(numCandidates-maxCandidate-1)*angleOpening / (numCandidates - 1));
      cmds.kicks[i] = vecToGoalBottom;
      if (maxOpening > maxOfOpenings) {
        maxOfOpenings = maxOpening;
        maxRobot = i;
      }
    }
    
    // first navigate to the ball as long as you're not touching the ball
//    PVector dribblerToBall = PVector.sub(myTeam.positions[1], ball.position);
//    if (dribblerToBall.mag() <= 14) { // touching the ball
      cmds.targets[1] = ball.position.get();
//    } else {
//      PVector ballToGoal = PVector.sub(otherGoalMid, ball.position);
//      ballToGoal.limit(5);
//      cmds.targets[1] = PVector.sub(ball.position, ballToGoal);
//    }
    if (this.side && cmds.targets[1].x < (1.0/8)*this.fieldWidth) {
      cmds.targets[1].x = (1.0/8)*this.fieldWidth;
    } else if (!this.side && cmds.targets[1].x > (7.0/8)*this.fieldWidth) {
      cmds.targets[1].x = (7.0/8)*this.fieldWidth;
    }
    cmds.kicks[1] = PVector.sub(myTeam.positions[maxRobot], myTeam.positions[1]);
    //cmds.kicks[1] = PVector.sub(otherGoalMid, myTeam.positions[1]);
    
    // goalie
    PVector v = PVector.sub(goalMid, ball.position);
    PVector goaliePos = ball.position.get();
    if (this.side && goaliePos.x < (7.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (7.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    } else if (!this.side && goaliePos.x > (1.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (1.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    }
    cmds.targets[0] = goaliePos;
    cmds.kicks[0] = PVector.sub(myTeam.positions[maxRobot], myTeam.positions[0]);
    
    return cmds;
  }
}
