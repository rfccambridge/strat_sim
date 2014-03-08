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
      PVector standard = PVector.add(ball.position, v);
      PVector newPos = new PVector();
      newPos.x = 100;
      newPos.y = 5;
      if (i< 3) {
        PVector d = new PVector(0,((i-1)*2 - 1)*robotRadius);
        newPos = PVector.add(standard, d);
        int r =  2 + (int) Math.ceil(2.0*Math.random()); 
        cmds.kicks[i] = PVector.sub(myTeam.positions[r],newPos); 
      }  
      
      if (2 < i && i < 5){
        int k = i - 3;
        newPos = PVector.sub(goalMid, standard);
        newPos.rotate(2*(k - 0.5)*60.0);
        newPos = PVector.add(goalMid, newPos);
        if (newPos.x > this.fieldWidth * .70){
          PVector d = new PVector(0,-1*(k*24 - 12)*robotRadius);
          newPos = PVector.add(standard, d);
          if (i == 3){
            cmds.kicks[i] = PVector.sub(myTeam.positions[5], myTeam.positions[i]);
          } else {
            cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
          } 
        }
        
        //PVector d = new PVector(0,((k-1)*30 - 15)*robotRadius);
        //newPos = PVector.add(newPos, d);
        //cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
        if (PVector.sub(ball.position, newPos).mag() < 150){
          newPos = ball.position;
        }
      }
      
      if (i == 5){
        newPos = new PVector();
        newPos.x = this.fieldWidth * 0.65;
        newPos.y = this.fieldHeight * 0.9;
        if (PVector.sub(ball.position, newPos).mag() < 250){
          newPos = ball.position;
        }
        cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
      }
      //if (i<2) {
         //newPos.x = 5.5;
         //newPos.y = 5.5;
      //}  else if (i < 4){
         //newPos = PVector.add(ball.position, v);
         //if (i<3){
           //newPos.y = newPos.y + (float)(40.0 * Math.pow((double) fieldWidth/ (double) ball.position.x, 1.3));
         //} else {
           //newPos.y = newPos.y - (float)(40.0 * Math.pow((double) fieldWidth/ (double)ball.position.x, 1.3));
         //}
      //} else {
        //if (i == 4){ 
          //v.y = v.y + 10.0;
        //}
        //if (i == 5) v.y = v.y - 10.0;
        //newPos = PVector.add(ball.position, v);
      //}
      //if (newPos.x < (this.fieldWidth/2.0)){
        //newPos.x = this.fieldWidth/2.0;
      //}
      
      if (this.side && newPos.x > ((7.0/8)*this.fieldWidth)) {
        newPos.x = (7.0/8)*this.fieldWidth;
      } else if (!this.side && newPos.x < ((4.0/8)*this.fieldWidth)) {
        newPos.x = (4.0/8)*this.fieldWidth;
      }
      cmds.targets[i] = newPos;
      //if (i < 4){
        //cmds.kicks[i] = PVector.sub(myTeam.positions[4], myTeam.positions[i]);
      //} else {
         //cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);
      //}
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
    int r =  2 + (int) Math.ceil(2.0*Math.random()); 
    cmds.kicks[0] = PVector.sub(myTeam.positions[r],goaliePos); 
    //cmds.kicks[0] = PVector.sub(otherGoalMid, myTeam.positions[0]);
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
