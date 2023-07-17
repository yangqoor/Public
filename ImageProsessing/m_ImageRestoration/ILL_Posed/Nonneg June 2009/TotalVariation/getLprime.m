function[L_prime] = getLprime(U,cost_params)

%  Extract needed items from cost_params.
  Dx1      = cost_params.Dx1;
  Dx2      = cost_params.Dx2;
  Dy1      = cost_params.Dy1;
  Dy2      = cost_params.Dy2;
  Delta_xy = cost_params.Delta_xy;
  n        = cost_params.nx;
  beta     = cost_params.beta;
  
  % Compute L'(U)U, defined in Vogel's book.
  DxU = Dx1*U(:); DyU = Dy1*U(:);
  Du_sq = DxU.^2 + DyU.^2;
  psi_doubleprime_comp = psi_doubleprime(Du_sq, beta);
  Dpsi_doubleprime_11 = spdiags(2*DxU.^2.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  Dpsi_doubleprime_12 = spdiags(2*DxU.*DyU.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  Dpsi_doubleprime_22 = spdiags(2*DyU.^2.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  L1 = Dx1' * Dpsi_doubleprime_11 * Dx1 + ...
       Dx1' * Dpsi_doubleprime_12 * Dy1 + ...
       Dy1' * Dpsi_doubleprime_12 * Dx1 + ...
       Dy1' * Dpsi_doubleprime_22 * Dy1;
  
  DxU = Dx2*U(:); DyU = Dy2*U(:);
  Du_sq = DxU.^2 + DyU.^2;
  psi_doubleprime_comp = psi_doubleprime(Du_sq, beta);
  Dpsi_doubleprime_11 = spdiags(2*DxU.^2.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  Dpsi_doubleprime_12 = spdiags(2*DxU.*DyU.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  Dpsi_doubleprime_22 = spdiags(2*DyU.^2.*psi_doubleprime_comp, 0, (n-1)^2,(n-1)^2);
  L2 = Dx2' * Dpsi_doubleprime_11 * Dx2 + ...
       Dx2' * Dpsi_doubleprime_12 * Dy2 + ...
       Dy2' * Dpsi_doubleprime_12 * Dx2 + ...
       Dy2' * Dpsi_doubleprime_22 * Dy2;
  
  L_prime = (L1 + L2) * Delta_xy / 2;
  