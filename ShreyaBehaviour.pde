/*class shreyabehaviour extends Behavior {

  Boolean side;
  float fieldWidth, fieldHeight, goalTop, goalBottom, goalWidth;
  PVector goalMid, otherGoalMid;
  
  public shreyabehaviour(Boolean side_, int fieldWidth_, int fieldHeight_, int goalTop_, int goalBottom_) {
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
    float othersd[] = new float[countB];
    for (int j=countA; j<countB+countA; j++)
        {othersd[i++]= (robots[i].position.x - ball.position.x)^2 + (robots[i].position.y - ball.position.y)^2;} 
    float minothers () { //stores the distances of all the opposing players from the ball.  
        float min = othersd[0]; 
        int i=1;
        if (othersd[j]<min)
        min=othersd[j];
        return min;} 
                         
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    Robots Cankick[] =new Robots[countB];
    int countcan=0;
    class problem 
    { int number;
      int maxproblem; 
    }
    problem problems[
    //For each robot, define the lines between the robot and the ends of the goal and check if the ball lies within the triangle so formed. 
    for (int i = 0; i < countB; i++){
      if ( (robots[i].position.x - goalTop.x)*ball.position.y + (goalTop.y - robots[i].position.y)*ball.position.x <= (-goalTop.y + robots[i].position.y)*robots[i].position.x +(robots[i].position.x - goalTop.x)*robots[i].position.y && (robots[i].position.x - goalBottom.x)*ball.position.y + (goalBottom.y - robots[i].position.y)*ball.position.x >= (-goalBottom.y + robots[i].position.y)*robots[i].position.x +(robots[i].position.x - goalBottom.x)*robots[i].position.y)
        {cankick[countcan]=robots[i]; 
         countcan++;
        }
    //For each of the selected robots, find the distance between the robot and the ball. Find the number of robots of the defence that lie within that distance of the ball (and the distance of each from it).  
    distance candistance[]= new distance[countcan]; 
    for (int i = 0; i <= countcan; i++){
      {candistance[i].balld =((robots[i].position.x - ball.position.x)^2 + (robots[i].position.y - ball.position.y)^2
        problem[i]=0; 
        for (int a=0; a<countA; a++)
        {if (s
         problem[i]++; 
          (
           if candistance[i]   
           
           
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
}*/
