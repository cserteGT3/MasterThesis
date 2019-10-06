using RANSAC
using Profile
using ProfileView

include("___usethis___.jl")
Profile.clear()
@profile ransac(pcr, RANSACParameters(p, itermax=20_000) , true);
ProfileView.view()
