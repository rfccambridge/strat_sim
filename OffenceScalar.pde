float HowOffensive(Robot robots[], SoccerBall ball)// assuming "we" are team red. The function takes the robots and the ball as its input 
                                                   //and uses their positions to determine how offensive a c ertain team's position is. 
{
  float scalar;
  int [] factors = {5,3,3,2,2}; 
  float [] ourdistances = new float [6];
  float [] theirdistances = new float [6];
  float sum=0;
  
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
        theirdistances[j-6]=diff2;
      }
    ourdistances=sort(ourdistances); 
    theirdistances=sort(theirdistances); 
    //float mediandiff= 500+ 
      for (int i=0; i<countR-1; i++)
        {sum+=(theirdistances[i]-ourdistances[i])*factors[i];} //If the median distance of "our" team from the ball is greater than the median distance of the other team, 
                                                            //our position is less offenive. Using the median seems to make sense here because it contains and uses information
                                                            //on the actual number of players within a certain radius. 
                                                            //The number added (5 for now) should make mediandiff positive so that the factor
                                                            //of the next line affects the scalar in the same way irrespective of whether the median difference is positive or negative.  
    
    float factor= pow((width/2)/(ball.position.x),(1/2)); // This takes into account the side of the field that the ball is on. The value is very large close to the goal and close to 1/2  
                                               //near the other goal. 
    float measure= sum +10000;
    scalar= measure*factor/500; 
    return scalar; 
    
}
   
    
        

