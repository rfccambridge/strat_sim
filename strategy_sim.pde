/**
 * Strategy Simulator
 * by Erik Schluntz, RFC Cambridge
 * 
 */
 
int goal_width = 100;

Robot[] robots;
int countA = 6; // goal is on the right
int countB = 6;

Behavior coachA;
Behavior coachB;

SoccerBall ball;

void setup() {
  size(800, 600);
  frameRate(30);
  
  robots = new Robot[countA+countB];
  ball = new SoccerBall();
  coachA = new BehaveFollow(true);
  coachB = new BehaveFollow(false);
  coachA.reset("start1");
  coachB.reset("start2");
  
  for (int i=0; i<countA; i++) {
    robots[i] = new Robot();
  }
  for (int i=countA; i<countB+countA; i++) {
    robots[i] = new Robot();
  }
  
  
}

void draw() {
  background(51);
  
  // thinking
  Team teamA = collect(robots,countA,countB,true);
  Team teamB = collect(robots,countA,countB,false);
  CmdSet cA = coachA.update(teamA,teamB,new SoccerBall(ball));
  CmdSet cB = coachB.update(teamB,teamA,new SoccerBall(ball));
  CmdSet cAll = new CmdSet(countA+countB);
  cAll.targets = (PVector[])concat(cA.targets,cB.targets);
  cAll.kicks = (Boolean[])concat(cA.kicks,cB.kicks);

  // updating
  for (int i = 0; i < countA+countB; i++) {
    Robot r = robots[i];
    r.instruct(cAll.targets[i], cAll.kicks[i]);
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
    for (int i = ca; i < cb; i++) {
      team.positions[i] = rs[i].position;
      team.velocities[i] = rs[i].velocity;
    }
  }
  return team;
}


