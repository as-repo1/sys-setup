# ==============================================================================
# Real-Time 60 FPS Video Interpolation using VapourSynth + SVPflow
# Location: ~/.config/mpv/svpflow_interpolation.vpy
# ==============================================================================
import vapoursynth as vs
import os
import sys

core = vs.core
core.max_cache_size = 4096

engine    = os.environ.get("FIS_ENGINE", "svpflow").lower()
target_fps = int(os.environ.get("FIS_TARGET_FPS", "60"))

# video_in is the magic variable mpv injects
clip = video_in

# ── helpers ────────────────────────────────────────────────────────────────────
def to_yuv420(c):
    if c.format.id != vs.YUV420P8:
        return core.resize.Bicubic(c, format=vs.YUV420P8)
    return c

def fix_fps(c):
    """If mpv passes VFR/unknown fps, assume 24."""
    if c.fps_num == 0 or c.fps_den == 0:
        c = core.std.AssumeFPS(c, fpsnum=24, fpsden=1)
    return c

# ── SVPflow (optical flow) ─────────────────────────────────────────────────────
def run_svpflow(clip):
    print(f"FIS: Starting SVPflow → {target_fps} fps", file=sys.stderr)

    # Load plugins if not already loaded
    if not hasattr(core, 'svp1'):
        try:
            core.std.LoadPlugin("/home/chaos/.config/vapoursynth/plugins/libsvpflow1.so")
            core.std.LoadPlugin("/home/chaos/.config/vapoursynth/plugins/libsvpflow2.so")
        except Exception as e:
            if "already loaded" not in str(e):
                print(f"FIS: SVPflow load error: {e}", file=sys.stderr)
                return None

    if not hasattr(core, 'svp1'):
        print("FIS: svp1 namespace missing after load attempt", file=sys.stderr)
        return None

    clip = to_yuv420(clip)
    clip = fix_fps(clip)

    # Attempt GPU mode first for massive performance gains
    try:
        sup   = core.svp1.Super(clip, "{gpu: 1}")
        vecs  = core.svp1.Analyse(
            sup["clip"], sup["data"], clip,
            "{gpu: 1, block: {w: 16, h: 16, overlap: 2}, "
            "search: {type: 4, distance: -8, SATD: false}}"
        )
        out = core.svp2.SmoothFps(
            clip, sup["clip"], sup["data"], vecs["clip"], vecs["data"],
            f"{{gpuid: 1, rate: {{num: {target_fps}, den: 1, abs: true}}, "
            f"algo: 13, mask: {{cover: 80}}, scene: {{mode: 0, limits: {{mblock: 4000}}}}}}"
        )
        print(f"FIS: SVPflow (GPU) OK → {out.fps_num}/{out.fps_den} fps", file=sys.stderr)
        return out
    except Exception as e:
        print(f"FIS: SVPflow GPU error: {e}\nFalling back to CPU...", file=sys.stderr)

    # CPU-only fallback
    try:
        sup   = core.svp1.Super(clip, "{gpu: 0}")
        vecs  = core.svp1.Analyse(
            sup["clip"], sup["data"], clip,
            "{gpu: 0, block: {w: 16, h: 16, overlap: 2}, "
            "search: {type: 4, distance: -8, SATD: false}}"
        )
        out = core.svp2.SmoothFps(
            clip, sup["clip"], sup["data"], vecs["clip"], vecs["data"],
            f"{{gpuid: 0, rate: {{num: {target_fps}, den: 1, abs: true}}, "
            f"algo: 13, mask: {{cover: 80}}, scene: {{mode: 0, limits: {{mblock: 4000}}}}}}"
        )
        print(f"FIS: SVPflow (CPU) OK → {out.fps_num}/{out.fps_den} fps", file=sys.stderr)
        return out
    except Exception as e:
        print(f"FIS: SVPflow CPU error: {e}", file=sys.stderr)
        return None

# ── RIFE / Vulkan (optional — needs vs-rife installed) ─────────────────────────
def run_rife(clip):
    print("FIS: Attempting RIFE (Vulkan)…", file=sys.stderr)
    if not hasattr(core, 'rife'):
        print("FIS: vs-rife not installed, falling back to SVPflow.", file=sys.stderr)
        return None
    try:
        clip_rgb = core.resize.Bicubic(clip, format=vs.RGBS, matrix_in_s="709")
        # multiplier: how many extra frames to insert
        mult = max(2, round(target_fps / max(clip.fps_num / max(clip.fps_den, 1), 1)))
        out = core.rife.RIFE(clip_rgb, model=9, gpu_id=0, multiplier=mult)
        out = core.resize.Bicubic(out, format=vs.YUV420P8, matrix_s="709")
        print(f"FIS: RIFE OK → {out.fps_num}/{out.fps_den} fps", file=sys.stderr)
        return out
    except Exception as e:
        print(f"FIS: RIFE error: {e}", file=sys.stderr)
        return None

# ── Routing ────────────────────────────────────────────────────────────────────
interpolated = None

if engine in ("rife_vulkan", "rife_trt"):
    interpolated = run_rife(clip)

# Always fall back to SVPflow
if interpolated is None:
    interpolated = run_svpflow(clip)

# Last resort: pass-through
if interpolated is None:
    print("FIS: All engines failed — passing through original video.", file=sys.stderr)
    clip.set_output()
else:
    interpolated.set_output()
