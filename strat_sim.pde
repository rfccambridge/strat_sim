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

void setup() {
  size(1000, 600);
  frameRate(30);
  
  robots = new Robot[countB+countR];
  ball = new SoccerBall();
  
  coachA = new BehaveNothing(false);
  coachR = new BehaveNothing(true);
  
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
  
  manualControl(robots,ball);
  
  time++;
  
  println(HowOffensive(robots,ball));
}

public void manualControl(Robot robots[], SoccerBall ball) {
  if (mousePressed) {
    PVector ms = new PVector(mouseX,mouseY);
    for (Robot robot:robots) {
      float dist = robot.position.dist(ms);
      if (dist < 30) {
        robot.position = ms.get();
        return;
      }
    }
    float dist = ball.position.dist(ms);
    if (dist < 30) {
      ball.position = ms.get();
      return;
    }
  } 
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


