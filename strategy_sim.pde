/**
 * RFC Comp
 * Goalie simulator
 * by Erik Schluntz
 * 
 * Write a behavior for the goalie to block the ball!
 */
 
Ball b;
Robot r;
int W = 600;
int H = 600;
int goal_height = 50;
int goal_width = 200;
int goal_y = H - goal_height;
int goal_xl = W / 2 - goal_width /2;
int goal_xr = W / 2 + goal_width /2;

int score;
int trials;

void setup() {
  size(W, H);
  if (testing_mode > 0)
    frameRate(30);
  else
    frameRate(120);
  fill(100);
  stroke(100);
  b = new Ball();
  r = new Robot();
  
  score = 0;
  trials = 0;
}

void draw() {
  
  background(51);
  rect(goal_xl, goal_y, goal_width, goal_height);
  line(0,goal_y,width,goal_y);
  b.update(r);
  if (testing_mode == 2)
    b.position.set(mouseX,mouseY);
  r.update(b);
  
  if (check_reset(b,r)) {
    b.reset();
    trials++;
    print("Score: " + score + " / " + trials + "\n");
  }
  
}


/*
returns true if the simulation should keep going
false if the simulation should stop
prints the result
*/
boolean check_reset(Ball b, Robot r) {
  if (testing_mode == 2)
    return(false);
  // first checking for goals
  if (b.position.x > goal_xl && b.position.x < goal_xr && b.position.y < height && b.position.y > goal_y) {
    print("goal\n");
    return(true);
  }
  if (b.position.x > width || b.position.x < 0 || b.position.y < 0 || b.position.y > height) {
    score++;
    print("blocked\n");
    return(true);
  }
  return(false); 
}
  




