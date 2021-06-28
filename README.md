This is a collection of my dotfiles, written in Nix.

### Profiles

I use `nix profile` to manage which packages I have installed. More specifically, I install the `buildEnv` packages in [profile.nix](./profile.nix). To try out the small set of tools I share across my laptop and servers, run:

```
nix shell github:aaronjanse/dotfiles#profiles.common
```
