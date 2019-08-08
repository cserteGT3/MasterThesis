vs, ns, norms4Plot, shape_s = examplepc3();
pcr = PointCloud(vs, ns, 32)
p = RANSACParameters{Float64}()
p = RANSACParameters(p, ϵ_plane=0.3, α_plane=deg2rad(5))
p = RANSACParameters(p, ϵ_cylinder=0.3, α_cylinder=deg2rad(5))
p = RANSACParameters(p, ϵ_sphere=0.3, α_sphere=deg2rad(5))
p = RANSACParameters(p, minsubsetN=15, prob_det=0.9, τ=900)
p = RANSACParameters(p, itermax=20, drawN=3)
ransac(pcr, p, true);
