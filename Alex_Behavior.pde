class BehaveAlexDefense extends BehaveBlockDefense {
  PVector goalPostTop;
  PVector goalPostBottom;
  PVector goalPostMid;
  public BehaveAlexDefense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_, false, fieldWidth_, fieldHeight_, goalTop_, goalBottom_);
    goalPostTop = new PVector(fieldWidth_, goalTop_);
    goalPostBottom = new PVector(fieldWidth_,goalBottom_);
    goalPostMid = new PVector(fieldWidth_, (goalTop_+goalBottom_)/2);
  }
  
  public int proximaTeam(Team team, Ball ball) {//returns index of closest team player to ball
    int closestPlayer=1;
    for(int i=1;i<team.n; i++){
      if((PVector.sub(team.positions[i],ball.position).mag())<(PVector.sub(team.positions[closestPlayer],ball.position)).mag()){
        closestPlayer=i;
      }
    }
      return closestPlayer;
  }
  public int proximaOther(Team team, Ball ball){//returns index of closest opponent player to ball
    int closestPlayer=1;
    for(int i=2;i<team.n; i++){
      if((PVector.sub(team.positions[i],ball.position)).mag()<(PVector.sub(team.positions[closestPlayer],ball.position)).mag()){
        closestPlayer=i;
      }
    }
      return closestPlayer;
  }
  
    public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    // Calculate vector between ball and goal
    PVector v = PVector.sub(goalMid, ball.position);
    float ballToGoal = v.mag();
    v.limit(ballToGoal / 2);
    //index of closest team player to ball
    int closestTeamPlayer= this.proximaTeam(myTeam, ball);
    //index of closest opponent to ball
    int closestOtherPlayer=this.proximaOther(otherTeam, ball);
    boolean otherPossess=false;
    if(PVector.sub(ball.position,otherTeam.positions[closestOtherPlayer]).mag()<35){
      otherPossess=true;
    }
    float distanceRatio;
    if(ball.position.x<.95*fieldWidth){
    distanceRatio=(.975*fieldWidth-ball.position.x)/(fieldWidth-ball.position.x);
    }
    else{
      distanceRatio = 1;
    }
    PVector ballToTop = PVector.sub(goalPostTop,ball.position);
    PVector ballToBottom = PVector.sub(goalPostBottom,ball.position);
    //possess behavior variables
    PVector shootTop = PVector.mult(ballToTop,distanceRatio);
    PVector shootBottom = PVector.mult(ballToBottom,distanceRatio);
    float creaseLength = (goalPostBottom.y-goalPostTop.y)*distanceRatio;
    float downCrease = (creaseLength*shootTop.mag())/(shootTop.mag()+shootBottom.mag());
    //free ball behavior variables
    boolean headingToGoal=false;
    if(PVector.angleBetween(ball.velocity,ballToTop)+PVector.angleBetween(ball.velocity,ballToBottom)>PVector.angleBetween(ballToTop,ballToBottom)){
      headingToGoal=true;
    }
    
    // Non goalie robots
    int otherIndex=1;
    //while(matcher<otherTeam.n){
      for (int i=1; i<n; i++) {
        PVector newPos;
        //directions for player closest to ball
        if(i==closestTeamPlayer&&ball.position.y>fieldWidth/3){
          if(PVector.sub(ball.position,myTeam.positions[i]).mag()<PVector.sub(ball.position,otherTeam.positions[closestOtherPlayer]).mag()){
            newPos=ball.position;
          }
          else{
            newPos=PVector.add(PVector.mult(goalPostMid,.3),PVector.mult(otherTeam.positions[closestOtherPlayer],.7));
          }
        }
        //directions for rest of team
        else{
          float backposition=0;
          for(int j=1; j<otherTeam.n;j++){
            if(backposition<otherTeam.positions[j].x){
              backposition = otherTeam.positions[j].x;
              }
          }
          if(backposition>.8*fieldWidth){
          float x = max(this.fieldWidth*2/3, backposition);
          float y= fieldHeight/2+(this.fieldWidth-x)/(this.fieldWidth*1.0/4)*(float)(i-3)/4*(fieldHeight/2);
          newPos= new PVector(x,y);
          }
          else{
          newPos = PVector.add(PVector.mult(ball.position,.1),PVector.mult(otherTeam.positions[i],.9));
          }
      }
      
      cmds.targets[i] = newPos;//call to indicator robot
      if(ball.position.y>fieldHeight/2){
      cmds.kicks[i] = PVector.sub(new PVector(random(0,.25)*fieldWidth,fieldHeight-random(0,.5)*fieldHeight), myTeam.positions[i]);//generates kicking positions of robots
      }
      else{
        cmds.kicks[i]= PVector.sub(new PVector(random(0,.25)*fieldWidth,random(0,.5)*fieldHeight), myTeam.positions[i]);
      }
    }
    //}
       
     // Goalie robot
      PVector goaliePos = PVector.mult(PVector.add(goalPostTop,goalPostBottom),.5);
      goaliePos= PVector.add(PVector.add(ball.position,shootTop),new PVector(0,downCrease));
      PVector ballToGoalie = PVector.sub(ball.position,goaliePos);
      
      if(headingToGoal&&ball.position.x>.7*fieldWidth){
        PVector velociPerp = new PVector(-ball.velocity.y,ball.velocity.x);
        velociPerp.normalize();
        PVector velDirect = PVector.mult(velociPerp,PVector.dot(velociPerp,ballToGoalie));
        PVector defendVelocity = PVector.add(PVector.mult(velDirect,.4),PVector.mult(ballToGoalie,.6));
        goaliePos=PVector.add(goaliePos,defendVelocity);
      }
      if(goaliePos.y<goalPostTop.y){
        goaliePos=new PVector(goaliePos.x,goalPostTop.y);
      }
      if(goaliePos.y>goalPostBottom.y){
        goaliePos = new PVector(goaliePos.x,goalPostBottom.y);
      }
      if(goaliePos.x<.85*fieldWidth){
        goaliePos = new PVector(.90*fieldWidth,goaliePos.y);
      }
      cmds.targets[0] = goaliePos;
      if(goaliePos.y>fieldHeight/2){
        cmds.kicks[0]= PVector.sub(new PVector((2.0/3+random(-2.0/3,0))*fieldWidth,fieldHeight),myTeam.positions[0]);
      }
      else{
      cmds.kicks[0] = PVector.sub(new PVector((2.0/3+random(-2.0/3,0))*fieldWidth, 0), myTeam.positions[0]);
      }
      return cmds;
  }
}
