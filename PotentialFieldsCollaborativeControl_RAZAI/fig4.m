clc; clear all; close all; color = 'kbgrcmy'; colorVal=1;

% Generate Random Start Points for Robots
numberOfRobots=2;
%robot=cell(1,numberOfRobots+1);

% robot=[ randi(robotX) ...
%         randi(robotY)]
     
 robot=[ ([14,12])
         ([14,14])];
 robotTminus1 = robot;
 robotTminus2 = robot;
 
figure; hold on; grid on;
axis([8 35 8 35]); axis square;

for i=1:numberOfRobots
    circle(robot(i,1),robot(i,2),0.2);
end

% Create Animated Line Objects for Each robot, different colors
robotTrajectory = [animatedline('Color',color(colorVal),'LineWidth',2)];
for i = 1: numberOfRobots-1
   colorVal = colorVal+1;
   if(colorVal>7)
       colorVal=1;
   end
   robotTrajectory = [robotTrajectory;animatedline('Color',color(colorVal),'LineWidth',2)];
end

x0 = 25;
y0 = 20;
v1=1; v2=5;
rectWidth =v1*2;
rectHeight=v2*2;

%Draw a rectangle
rectangle('Position',[x0-v1 y0-v2 rectWidth rectHeight]);%,'FaceColor',[1 0 0]);
% ellipse(x0,y0,3,2);
% ellipse(x0,y0,6,4);

A=sqrt(1/(2*((v1)^2)));
B=sqrt(1/(2*((v2)^2)));

ellipse(x0,y0,1/A,1/B);

ra = 0.5; % ZP, 1
rk = zeros(numberOfRobots,1);

fxkdes = zeros(numberOfRobots,1);
fykdes = zeros(numberOfRobots,1);

% for figure 4
fxkdes = [8;8];
fykdes = [8;8];

fxkOA = zeros(numberOfRobots,1);
fykOA = zeros(numberOfRobots,1);

M=1;
Bz=1;
kd=9;

xdot = zeros(numberOfRobots,1);
ydot = zeros(numberOfRobots,1);

psi = zeros(numberOfRobots,1);
chi = zeros(numberOfRobots,1);

FORCE_MAX = 100;

t = 0;
%while WayPoint<(length(trajectory)-1)
while t<400
    t = t+1;
    for i=1:numberOfRobots
        xk = robot(i,1);
        yk = robot(i,2);
        
        rk(i) =sqrt(((A^2*(xk-x0)^2+B^2*(yk-y0)^2-1)));
        chi(i)=atan2(y0-yk,x0-xk);
        
        if(t>3)
            xy_coordinate=(robotTminus1(i,:)-robotTminus2(i,:));
            psi(i)=atan2((-A/B).*xy_coordinate(1),(B/A).*xy_coordinate(2));
        end
        
        if(mod(psi(i)-chi(i),2*pi)<=pi)            
            fxkrc  =  (B/A)*(yk-y0);
            fykrc  = -(A/B)*(xk-x0);            
            fxkr   = fxkrc;
            fykr   = fykrc;
        else
            fxkrcc = -(B/A)*(yk-y0);
            fykrcc =  (A/B)*(xk-x0);
            fxkr   = fxkrcc;
            fykr   = fykrcc;
        end

        fxkrn = fxkr/norm([fxkr;fykr]);
        fykrn = fykr/norm([fxkr;fykr]);

        if(rk(i)<=ra)
            fxkOA(i) = fxkdes(i) + ((g(fxkdes(i),fykdes(i))*fxkrn)/rk(i)^2)*((1/rk(i))-(1/ra));
            fykOA(i) = fykdes(i) + ((g(fxkdes(i),fykdes(i))*fykrn)/rk(i)^2)*((1/rk(i))-(1/ra));
        else
            fxkOA(i) = fxkdes(i);
            fykOA(i) = fykdes(i);
        end
        
        if(abs(fxkOA(i))>FORCE_MAX)
            fxkOA(i)=(fxkOA(i)/abs(fxkOA(i)))*FORCE_MAX;
        end
        if(abs(fykOA(i))>FORCE_MAX)
            fykOA(i)=(fykOA(i)/abs(fykOA(i)))*FORCE_MAX;
        end

        fx = @(t,x) [x(2); (fxkOA(i)-(Bz+kd)*x(2))/M];
        [T,X]=ode45(fx,[0,0.05],[xk;xdot(i)]);
        [m,z] = size(X);
        xk=X(m,1);
        xdot(i)=X(m,2);

        fy = @(t,y) [y(2); (fykOA(i)-(Bz+kd)*y(2))/M];
        [T,Y]=ode45(fy,[0,0.05],[yk;ydot(i)]);
        [m,z] = size(Y);
        yk=Y(m,1);
        ydot(i)=Y(m,2);
        
        robotTminus2(i,:) = robotTminus1(i,:);
        robotTminus1(i,:) = robot(i,:);
        robot(i,:)=[xk yk];
        addpoints(robotTrajectory(i),xk,yk);
        drawnow
    end
end

for i=1:numberOfRobots
    circle(robot(i,1),robot(i,2),0.2);
end