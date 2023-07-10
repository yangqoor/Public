module Constant
implicit none
integer,parameter::npre=100000,nsample=50000
integer,parameter::dimen=40,num=1
real(8),parameter::h=0.05,a=8.0
integer,parameter::ncycle=350,bcycle=4
integer,parameter::nstep=1500,step=1
real(8),parameter::dl=0.00001
end module

program main
use Constant
implicit none
call random_seed()
open(21,file='/disk1/home/ljp/fengjie/lorenz96/nlle/lya_longer.grd',&
form='unformatted',access='direct',recl=nstep*dimen)
open(22,file='/disk1/home/ljp/fengjie/lorenz96/nlle/lyai_longer.grd',&
form='unformatted',access='direct',recl=nstep*dimen)
open(23,file='/disk1/home/ljp/fengjie/lorenz96/nlle/rgie_longer.grd',&
form='unformatted',access='direct',recl=nstep*dimen)
call ftle()
end program


!-----------------------------------------------------
!!!!!ftle: calculate nonlinear finite time lyapunov exponent
Subroutine ftle()
use Constant
implicit none
integer::i,ind,j,flag
real(kind=8)::yn(dimen),state(dimen),start(dimen)
real(kind=8)::lya0(dimen,nstep),lyai0(dimen,nstep),rgie0(dimen,nstep)
real(kind=8)::error0(dimen,num)
real(kind=8)::NLLV(dimen,num)
flag=0
	
lya0=0.
lyai0=0.
rgie0=0.

!----enter the attractor
	yn(1)=1.0
	yn(2)=1.3
	yn(3)=0.31
	yn(4)=-0.3
	yn(5)=1.2
	yn(6)=-0.37
	yn(7)=0.5
	yn(8)=-2.0
	yn(9)=0.6
	yn(10)=0.32
	yn(11)=1.9
	yn(12)=-0.63
	yn(13)=1.25
	yn(14)=-0.265
	yn(15)=-0.378
	yn(16)=0.256
	yn(17)=-0.65
	yn(18)=0.98
	yn(19)=-0.476
	yn(20)=0.188
	yn(21)=-0.954
	yn(22)=0.54
	yn(23)=0.367
	yn(24)=1.23
	yn(25)=0.323
	yn(26)=-0.87
	yn(27)=-1.11
	yn(28)=-0.444
	yn(29)=1.09
	yn(30)=-0.656
	yn(31)=0.360
	yn(32)=-0.619
	yn(33)=0.65
	yn(34)=-7.5
	yn(35)=0.812
	yn(36)=-0.65
	yn(37)=0.53
	yn(38)=2.29
	yn(39)=-0.9
	yn(40)=0.34
!-----spin up-----
	call enter(h,a,npre,dimen,yn)
!------------------------------------------		
 outer:	do ind=1,nsample
		write(*,*)ind
		state=0.
		state(:)=yn(:)
		call rk4(dimen,yn,h,a)    !move to next initial state
		!----generate initial random errors
		do j=1,dimen
			call error_R(dl,dimen,error0(:,j))
		end do
		!--------------------------
		NLLV=0.
		call reorth(state,error0,NLLV,start)
		call reorth_errorgrow(start,NLLV,lya0,lyai0,rgie0)
		write(21,rec=ind)real(lya0)
		write(22,rec=ind)real(lyai0)
		write(23,rec=ind)real(rgie0)
	enddo outer
return      
end subroutine


!------------------------------------------------------------
!!!!m is the number of variable,yn is value of input variable, also the output value through one step.
!!!!each call --> one step forward
subroutine rk4(m,yn,h,a)
implicit none
integer::m,i,j
real(kind=8)::a
real(kind=8)::yn(m),h
real(kind=8)::y(m),y0(m),dy(m),u(5)
	u(1)=h/2.0
	u(2)=u(1)
	u(5)=u(1)
	u(3)=h
	u(4)=h
    do i=1,m
	y0(i)=yn(i)
    	 y(i)=yn(i)
    end do
    do j=1,4
        call dif(m,y,dy,a)
        do i=1,m
		yn(i)=yn(i)+u(j+1)*dy(i)/3.0
		y(i)=y0(i)+u(j)*dy(i)
	end do
    end do
return
end
!!!!------------------------------------------------------------


!-----------------------------------------------------------------------
!y is variable, dy is variable differential with respect to t;r,b,p is the parameter.
subroutine dif(m,y,dy,a)
implicit none
integer::m,i
real(kind=8)::dy(m),y(m)
real(kind=8)::a
        dy(1)=(y(2)-y(39))*y(40)-y(1)+a
	dy(2)=(y(3)-y(40))*y(1)-y(2)+a
	do i=3,39
		dy(i)=(y(i+1)-y(i-2))*y(i-1)-y(i)+a
	end do
	dy(40)=(y(1)-y(38))*y(39)-y(40)+a

	!dy(41)=(y(42)-y(79))*y(40)+(y(2)+y(42)-y(39)-y(79))*y(80)-y(41)
	!dy(42)=(y(43)-y(80))*y(1)+(y(3)+y(43)-y(40)-y(80))*y(41)-y(42)
	!do i=3,39
		!dy(i+40)=(y(i+41)-y(i+38))*y(i-1)+(y(i+1)+y(i+41)-y(i-2)-y(i+38))*y(i+39)-y(i+40)
	!end do
	!dy(80)=(y(41)+y(78))*y(39)+(y(1)+y(41)-y(38)-y(78))*y(79)-y(80)
return
end
!!------------------------------------------------------------------------

!!-------------------------------------------------------------------------
!-----input:
!       dimen:the number of real variables,not error variables
!       error(dimen,dimen): the error vectors to be made the process of GSR.
!-----output:
!       errorout(dimen,dimen): output final error vectors
subroutine gsr(m,n,error,errorout)
implicit none
integer::m,n,i,j,k
real(kind=8)::yout(m)
real(kind=8)::error(m,n),errorout(m,n)
do i=1,m
        do j=1,n
                errorout(i,j)=error(i,j)
        end do
end do
do i=2,n
        do j=1,i-1
                call project(m,errorout(:,j),error(:,i),yout)
                do k=1,m
                        errorout(k,i)=errorout(k,i)-yout(k)
                end do
        end do
end do

return
end subroutine
!!!!----------------------------------------------------------------------

!!!input: 
!!!--dimen : dimension
!!!--error(dimen,dimen): the error vectors to be GSR
!!!output:
!!!--errorout(dimen,dimen): output result
subroutine gsr_stan(m,n,error,dl,errorout)
implicit none
integer::i,j,k,m,n
real(kind=8)::dl
real(kind=8)::yout(m)
real(kind=8)::error(m,n),errorout(m,n)
call gsr(m,n,error,errorout)
        
do i=1,n
        call standard(m,errorout(:,i),dl,yout)
        errorout(:,i)=yout(:)
end do

return
end subroutine
!-------------------------------------------------

!!!------------------------------------------------------------------------
!!!!make standerlised process on x(dimen), the final magnitude is dl.The output is y(dimen)
subroutine standard(dimen,x,dl,y)
implicit none
integer::dimen,i
real(kind=8)::x(dimen),dd,y(dimen)
real(kind=8)::dl
dd=0.
do i=1,dimen
	dd=dd+x(i)*x(i)
end do
dd=sqrt(dd/real(dimen))
do i=1,dimen
	y(i)=x(i)*dl/dd
end do
return
end
!!------------------------------------------------------------------------ 

!-----------------------------------------------------------
!!!calculate projection of y on x
!----output:
!-----yout(dimen): projection of y on x
subroutine project(m,x,y,yout)
implicit none
integer::i,m
real(kind=8)::x(m),y(m),yout(m)
real(kind=8)::d2,d1
d1=0.
d2=0.
do i=1,m
        d2=d2+x(i)*y(i)
        d1=d1+x(i)*x(i)
end do
do i=1,m
        yout(i)=d2*x(i)/d1
end do
return
end subroutine
!--------------------------------------------------

!----------------------------------------------------------------------
!!---This subroutine evolves the variables into attractors
!----input:
!      h:integral step
!      n:the number of evolutionary steps
!      m:the number of variables
!      yn(m):initial values of variables
!----output:
!      yn(m):output values of variables
subroutine enter(h,a,n,m,yn)
implicit none
integer::n,m,ind
real(kind=8)::yn(m)
real(kind=8)::h,a
        do ind=1,n
                call rk4(m,yn,h,a)
        end do
return
end
!!----------------------------------------------------------------------


!!!---------------------------------------------------------------------
!!!reorthogonalization: repeat use of the GSR procedure on the vector frame
subroutine reorth(state,error,errorout,start)
use Constant
implicit none
integer::k,i,j
real(kind=8)::state(dimen),start(dimen),error(dimen,dimen)
real(kind=8)::error0(dimen,dimen),error1(dimen,dimen)
real(kind=8)::yn0(dimen),yn0_p(dimen)
real(kind=8)::errorout(dimen,dimen)
!----------------
error0=error
!---------------
do k=1,ncycle
  inner:do i=1,dimen
		!----input initial state/initial error
		yn0=0.
		yn0_p=0.
		yn0=state
		yn0_p(:)=state(:)+error0(:,i)
		!----------------------------
		do j=1,bcycle
			call rk4(dimen,yn0,h,a)
			call rk4(dimen,yn0_p,h,a)
		end do
		error1(:,i)=yn0_p(:)-yn0(:)
	end do inner
	!---update the initial state
	state=yn0
	!------------------------
	error0=0.
	call gsr_stan(dimen,dimen,error1,dl,error0)
end do
errorout=error0
start=yn0
return
end subroutine
!!!---------------------------------------------------------------

!!!---------------------------------------------------------------------
!!!reorthogonalization: repeat use of the GSR procedure on the vector frame
subroutine reorth_errorgrow(state,error,lya,lyai,rgie)
use Constant
implicit none
integer::k,i,j
real(kind=8)::state(dimen),error(dimen,dimen)
real(kind=8)::error0(dimen,dimen),error1(dimen,dimen)
real(8)::yn0(dimen),yn0_p(dimen)
real(kind=8)::lya(dimen,nstep),lyai(dimen,nstep),rgie(dimen,nstep)
!----------------
error0=error
!---------------
do k=1,nstep
  inner:do i=1,dimen
                !----input initial state/initial error
                yn0=0.
                yn0_p=0.
                yn0=state
                yn0_p(:)=state(:)+error0(:,i)
                !----------------------------
                do j=1,step
                        call rk4(dimen,yn0,h,a)
                        call rk4(dimen,yn0_p,h,a)
                end do
                error1(:,i)=yn0_p(:)-yn0(:)
        end do inner
        !---calculate the lya,lyai,rgie
        call NLLEs(k,step,h,dimen,dimen,error,error0,error1,lya(:,k),lyai(:,k),rgie(:,k))
        !---update the initial state
        state=yn0
        !------------------------
        error0=0.
        call gsr(dimen,dimen,error1,error0)
end do
!errorout=error0
return
end subroutine
!!!---------------------------------------------------------------


        !------------------------------------------------
        !!!!form random error of random distribution
        !!!stan is the rescaling size
        subroutine error_R(stan,n,x)
        implicit none
        real(8)::a,stan
        integer::i,n
        real(8)::xtemp(n),x(n)

        do i=1,n
                call random_number(a)
                a=a-0.5
                xtemp(i)=a
        end do

        call standard(n,xtemp,stan,x)
        return
        end subroutine
        !---------------------------------------------right

subroutine NLLEs(nt,step,dt,m,n,error,error0,error1,lya,lyai,rgie)
implicit none
integer::nt,step,m,n
integer::i
real(8)::dt
real(8)::error(m,n),error0(m,n),error1(m,n)
real(8)::lya(n),lyai(n),rgie(n)
real(8)::d0,d1,d2
do i=1,n
	call norm(m,error(:,i),d0)
	call norm(m,error0(:,i),d1)
	call norm(m,error1(:,i),d2)
	lyai(i)=log(d2/d1)/real(step*dt)
	rgie(i)=log(d2/d0)
	lya(i)=rgie(i)/real(nt*step*dt)
end do
return
end subroutine

subroutine norm(n,e,d)
implicit none
integer::n
real(8)::e(n)
real(8)::d,summ
integer::i
summ=0.
do i=1,n
	summ=summ+e(i)*e(i)
end do
d=sqrt(summ/real(n))
return
end subroutine


