/**
 * Strategy Simulator
 * by Erik Schluntz, RFC Cambridge
 * 
 */
 
int goal_width = 150;

Robot[] robots;
int countA = 6; // goal is on the right
int countB = 6;

int scoreA = 0;
int scoreB = 0;
int time = 0;

Behavior coachA;
Behavior coachB;

SoccerBall ball;

void setup() {
  size(1000, 600);
  frameRate(30);
  
  robots = new Robot[countA+countB];
  ball = new SoccerBall();
  coachA = new BehavePointDefense(true, width, height, (height-goal_width)/2, (height+goal_width)/2);
  coachB = new BehaveSimplePassOffense(false, width, height, (height-goal_width)/2, (height+goal_width)/2);
  
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
  Team teamA = collect(robots,countA,countB,true);
  Team teamB = collect(robots,countA,countB,false);
  CmdSet cA = coachA.update(teamA,teamB,new SoccerBall(ball));
  CmdSet cB = coachB.update(teamB,teamA,new SoccerBall(ball));
  CmdSet cAll = new CmdSet(countA+countB);
  cAll.targets = (PVector[])concat(cA.targets,cB.targets);
  cAll.kicks = (PVector[])concat(cA.kicks,cB.kicks);

  // updating
  for (int i = 0; i < countA+countB; i++) {
    Robot r = robots[i];
    r.instruct(cAll.targets[i], cAll.kicks[i],ball);
    r.update();
    r.checkBoundaryCollision();
    ball.checkCollision(r);
    
    // checking collision
    for (int j = i + 1; j < countA+countB; j++) {
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
  println("TeamA: " + scoreA + " TeamB: " + scoreB + " time: " + time);
  coachA.reset("start1");
  coachB.reset("start2");
  
  for (int i=0; i<countA; i++) {
    robots[i] = new Robot(true);
  }
  for (int i=countA; i<countB+countA; i++) {
    robots[i] = new Robot(false);
  }
  
  ball = new SoccerBall();
}

// takes a slice of the list and turns it into a team object
public Team collect(Robot[] rs, int ca, int cb, Boolean forward) {
  Team team;

  if (forward) {
    team = new Team(ca);
    for (int i = 0; i < ca; i++) {
      team.positions[i] = rs[i].position;
      team.velocities[i] = rs[i].velocity;
    }
  }
  else {
    team = new Team(cb);
    for (int i = ca; i < ca+cb; i++) {
      team.positions[i-ca] = rs[i].position;
      team.velocities[i-ca] = rs[i].velocity;
    }
  }
  return team;
}


