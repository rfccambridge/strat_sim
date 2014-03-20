/**
 * Strategy Simulator
 * by Erik Schluntz, RFC Cambridge
 * 
 */
 int goal_width = 150;
 int countB = 6; // defends the right
int countR = 6; // defends the left

int scoreB = 0;
int scoreR = 0;
int time = 0;

int robotRadius=2; //provisionally

 abstract class Ball {
  
  PVector position;
  PVector velocity;
  
  // how bouncy the ball is
  float bnc = -.5;
  float spring = .4;
  float damp = -.3;
  float r, m;
  color c;

  Ball(float x, float y, float r_, float m_, color c_) {
    position = new PVector(x, y);
    velocity = new PVector(0,0);
    r = r_;
    m = m_;
    c = c_;
  }

  public void update() {
    position.add(velocity);
    //velocity.mult(.9);
    strokeWeight(1);
    stroke(51);
    fill(c);
    ellipse(position.x,position.y,2*r,2*r);
  }

  public void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= bnc;
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= bnc;
    } 
    if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= bnc;
    } 
    else if (position.y < r) {
      position.y = r;
      velocity.y *= bnc;
    }
  }

  public void checkCollision(Ball other) {

    // get distances between the balls components
    PVector dx = PVector.sub(other.position, position);
    PVector dv = PVector.sub(other.velocity, velocity);
    
    float mindist = r + other.r;
    if (dx.mag() < mindist) {
      // calculate spring component
      PVector indent = dx.get();
      indent.setMag(mindist);
      indent.sub(dx);
      PVector Fs = PVector.mult(indent,spring);
      
      // calculate damping
      PVector dx_hat = dx.get();
      dx_hat.normalize();
      float dot = dv.dot(dx_hat) * damp;
      PVector Fd = dx_hat.get();
      Fd.mult(dot);
      PVector accel = PVector.add(Fs,Fd);
      velocity.sub(accel);
      other.velocity.add(accel);
      
    }
  }
}
 
 class SoccerBall extends Ball {
  
  float friction = .14;
  
  public SoccerBall() {
    super(width/2,height/2,4,4, color(150));
  }
  
  public SoccerBall(Ball b) {
    super(0,0,1,1,color(0));
    this.position = b.position.get();
    this.velocity = b.velocity.get();
  }
  
  public void update() {
    if (this.velocity.mag() < friction) {
      this.velocity.mult(0);
    }
    else {
      this.velocity.setMag(this.velocity.mag() - friction);
    }
    super.update();
  }
  
    public void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= bnc;
      
      if (abs(position.y - height/2) < goal_width/2) {
        // goal
        scoreR++;
        reset();
      }
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= bnc;
      if (abs(position.y - height/2) < goal_width/2) {
        // goal
        scoreB++;
        //reset();
      }
    } 
    if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= bnc;
    } 
    else if (position.y < r) {
      position.y = r;
      velocity.y *= bnc;
    }
    }

}
 
class Robot extends Ball {
  
  // movement
  float max_accel = 3;

  float drag = .7;;  
  // kicking

  float kick_speed = 20;
  float noise_scale = 2; 
  float kick_range = 10;
  
  
  
  public Robot() {
    super(random(width),random(height),10,13,color(100,100,100));
  }
  public Robot(Boolean side) {
    //true means start on right
    this();
    this.position.x = random(width/2);
    this.position.y = random(height);
    
    this.c = color(200,51,51);
    
    if (side) {
      this.position.x += width/2;
      this.c = color(51,51,200);
    }
  }
  
  public void instruct(PVector target, PVector kick, SoccerBall ball) {
    // go to target
    PVector accel = PVector.sub(target,position);
    accel.setMag(accel.mag()*accel.mag()/100);
    accel.limit(max_accel);
    velocity.add(accel);

    velocity.mult(drag);    
    // kicking
    if (kick != null && kick.mag() != 0) {
      

  
      kick.normalize();

      float dist = PVector.sub(ball.position,position).mag();
      
      
      
      if (dist < kick_range + r + ball.r) {
        // in kicking range
        kick.setMag(kick_speed);
        PVector noise = PVector.random2D();
        noise.mult(noise_scale);
        kick.add(noise);
        ball.velocity = kick.get();
      }
    } 
  }
}

// group of robot information for passing to behavior
class Team {
  int n;
  PVector[] positions;
  PVector[] velocities;
  
  public Team(int n_) {
    n = n_;
    positions = new PVector[n];
    velocities = new PVector[n];
    
    for (int i=0; i < n; i++) {
      positions[i] = new PVector();
      velocities[i] = new PVector();
    }
  }
}

// for passing instructions back from behavior
class CmdSet {
  int n;
  PVector[] targets;
  PVector[] kicks;
  
  public CmdSet(int n_) {
    n = n_;
    targets = new PVector[n];
    kicks = new PVector[n];
    
    for (int i=0; i<n; i++) {
      targets[i] = new PVector();
      kicks[i] = null;
    }
  }
}
    
abstract class Behavior {  
  // declare any variables you need between steps here

  // true means defend the right
  Behavior(Boolean side) {
  }
  
  abstract void reset(String msg);

  abstract CmdSet update(Team myTeam, Team otherTeam, Ball ball);
}


class BehaveSimplePassOffense extends Behavior {
  
  Boolean side;
  float fieldWidth, fieldHeight, goalTop, goalBottom, goalWidth;
  PVector goalMid, otherGoalMid;
  
public BehaveSimplePassOffense(Boolean side_, int fieldWidth_, int fieldHeight_, int goalTop_, int goalBottom_) {
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


class BehaveBlockDefense extends Behavior {
  
  Boolean side, wall;
  float fieldWidth, fieldHeight, goalTop, goalBottom;
  PVector goalMid, otherGoalMid;
  
  public void reset(String msg) {
  }
  
  
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


  
//int goal_width = 150;

Robot [] robots;
/*int countB = 6; // defends the right
int countR = 6; // defends the left

int scoreB = 0;
int scoreR = 0;
int time = 0;*/

Behavior coachA;
Behavior coachR;

SoccerBall ball;

float HowOffensive(Robot robots[], SoccerBall ball)// assuming "we" are team red. The function takes the robots and the ball as its input 
                                                   //and uses their positions to determine how offensive a c ertain team's position is. 
{
  float scalar;
  float [] ourdistances = new float [6];
  float [] theirdistances = new float [6];
  
    for (int i=0; i<countR; i++)
        {
         PVector v1 = robots[i].position;
         PVector v2 = ball.position; 
       PVector v3 = PVector.sub(v1,v2);
        float diff1 = v3.mag(); 
        ourdistances[i]=diff1;}
    int a=0;
    for (int j=countR; j<countR+countB; j++)
      { PVector b1 = robots[j].position;
         PVector b2 = ball.position; 
       PVector b3 = PVector.sub(b1,b2);
        float diff2 = b3.mag(); 
        theirdistances[a++]=diff2;
      }
    ourdistances=sort(ourdistances); 
    theirdistances=sort(theirdistances); 
    float mediandiff= 5+ theirdistances[3]-ourdistances[3]; //If the median distance of "our" team from the ball is greater than the median distance of the other team, 
                                                            //our position is less offenive. Using the median seems to make sense here because it contains and uses information
                                                            //on the actual number of players within a certain radius. 
                                                            //The number added (5 for now) should make mediandiff positive so that the factor
                                                            //of the next line affects the scalar in the same way irrespective of whether the median difference is positive or negative.  
    
    float factor= (width/2)/(ball.position.x); // This takes into account the side of the field that the ball is on. The value is very large close to the goal and close to 1/2  
                                               //near the other goal. 
    scalar= mediandiff*factor; 
    return scalar; 
    
}


void setup() {
  size(1000, 600);
  frameRate(30);
  
  robots = new Robot[countB+countR];
  ball = new SoccerBall();
  
  //Checking whether offence or defence, 
  if (HowOffensive(robots, ball)<=5){
  coachA = new BehaveSimplePassOffense(false, width, height, (height-goal_width)/2, (height+goal_width)/2);
  coachR = new BehaveBlockDefense(true, true, width, height, (height-goal_width)/2, (height+goal_width)/2);
  }
  else if (HowOffensive(robots, ball)>5){
  coachR = new BehaveSimplePassOffense(false, width, height, (height-goal_width)/2, (height+goal_width)/2);
  coachA = new BehaveBlockDefense(true, true, width, height, (height-goal_width)/2, (height+goal_width)/2);
  }
  reset();
}

void draw() {
  // drawing field
  background(51);
  fill(51,150,51);
  rect(0,(height-goal_width)/2,5,goal_width);
  rect(width-5,(height-goal_width)/2,5,goal_width);
  stroke(100);
  strokeWeight(2);
  line(width/2,0,width/2,height);
  noFill();
  ellipse(width/2,height/2,200,200);
  
  // thinking
  Team scoreB = collect(robots,countB,countR,true);
  Team teamR = collect(robots,countB,countR,false);
  CmdSet cB = coachA.update(scoreB,teamR,new SoccerBall(ball));
  CmdSet cR = coachR.update(teamR,scoreB,new SoccerBall(ball));
  CmdSet cAll = new CmdSet(countB+countR);
  cAll.targets = (PVector[])concat(cB.targets,cR.targets);
  cAll.kicks = (PVector[])concat(cB.kicks,cR.kicks);

  // updating
  for (int i = 0; i < countB+countR; i++) {
    Robot r = robots[i];
    r.instruct(cAll.targets[i], cAll.kicks[i],ball);
    r.update();
    r.checkBoundaryCollision();
    ball.checkCollision(r);
    
    // checking collision
    for (int j = i + 1; j < countB+countR; j++) {
      r.checkCollision(robots[j]);
    }
  }
  
  //soccer ball
  ball.update();
  ball.checkBoundaryCollision();
  
  time++;
}

public void reset() {
  println("Goal!");
  println("TeamA: " + scoreB + " Team Red: " + scoreR + " time: " + time);
  coachA.reset("start1");
  coachR.reset("start2");
  
  for (int i=0; i<countB; i++) {
    robots[i] = new Robot(true);
  }
  for (int i=countB; i<countR+countB; i++) {
    robots[i] = new Robot(false);
  }
  
  ball = new SoccerBall();
}

// takes a slice of the list and turns it into a team object
public Team collect(Robot[] rs, int cb, int cr, Boolean forward) {
  Team team;

  if (forward) {
    team = new Team(cb);
    for (int i = 0; i < cb; i++) {
      team.positions[i] = rs[i].position;
      team.velocities[i] = rs[i].velocity;
    }
  }
  else {
    team = new Team(cr);
    for (int i = cb; i < cb+cr; i++) {
      team.positions[i-cb] = rs[i].position;
      team.velocities[i-cb] = rs[i].velocity;
    }
  }
  return team;
}


