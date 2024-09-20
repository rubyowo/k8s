{
  description = "k8s devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = let
            custom-kubernetes-helm = with pkgs;
              wrapHelm kubernetes-helm {
                plugins = with pkgs.kubernetes-helmPlugins; [
                  helm-secrets
                  helm-diff
                  helm-git
                ];
              };
            custom-helmfile = pkgs.helmfile-wrapped.override {
              inherit (custom-kubernetes-helm) pluginsDir;
            };
          in
            with pkgs; [
              kubectl
              kluctl
              k9s
              custom-helmfile
              custom-kubernetes-helm
              sops
              age
            ];
          env = {
            KUBECONFIG = "/home/rei/kubeconfig/kubeconfig.yaml";
            SOPS_AGE_KEY_FILE = "/home/rei/kubeconfig/kluctl.age";
          };
        };
      }
    );
}
