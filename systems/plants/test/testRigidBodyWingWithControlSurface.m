function xtraj = testRigidBodyWingWithControlSurface()

  % Tests control surfaces by creating from a URDF that has control surfaces
  % and simulating.

  %% Construct from URDF


  disp('Constructing from URDF...');

  options.floating = true;
  r = RigidBodyManipulator('testRigidBodyWingWithControlSurface.urdf', options);
  v = r.constructVisualizer();

  % Visualize the constructed wing with the wing-drawing tools

  q = zeros(r.getNumContStates(),1);
  qd = zeros(r.getNumContStates(),1);
  clf
  for i = 1 : length(r.force)
    plot3(0, 0, 0, '*');
    if isa(r.force{i}, 'RigidBodyCompositeWing') || isa(r.force{i}, 'RigidBodyWing')
      r.force{i}.drawWing(r, q, qd, [rand() rand() rand()]);
    end
  end

  %% simulate

  disp('Simulating...');

  x0 = [0; 0; 0; 0; 0; 0; 15; 0; 0; 0; 0; 0];
  end_t = .5;

  constant_traj = ConstantTrajectory([0.8 0.8 100]);
  constant_traj = constant_traj.setOutputFrame(r.getInputFrame());

  feedback_system = cascade(constant_traj, r);

  [ytraj, xtraj] = feedback_system.simulate([0 end_t], x0);

  v.playback(xtraj)

  final_x = xtraj.eval(end_t);


  assert(final_x(1) > 5) % should move forward
  assert(abs(final_x(2)) < .1) % should stay in the center
  assert(final_x(3) > 1); % should gain altitude

end