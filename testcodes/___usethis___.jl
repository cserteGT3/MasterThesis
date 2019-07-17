vs, ns, norms4Plot, shape_s = examplepc3();
pcr = PointCloud(vs, ns, 32);
p_ae = (ϵ = 0.3, α=deg2rad(5));
cy_ae = (ϵ = 0.3, α=deg2rad(5));
sp_ae = (ϵ = 0.3, α=deg2rad(5));
one_ae = AlphSilon(sp_ae, p_ae, cy_ae);
tt = 15;
ptt = 0.9
ττ = 900
# maximum number of iteration
itermax = 20
draws = 3
ransac(pcr, one_ae, tt, ptt, ττ, itermax, draws, 500, true);