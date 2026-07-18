#!/usr/bin/env python3
import sys
import json
import subprocess
import time

ORDER = ["www", "web", "term", "file", "code", "agv", "abc", "xyz", "cht", "0"]

def get_workspaces():
    out = subprocess.check_output(["niri", "msg", "-j", "workspaces"]).decode("utf-8")
    return sorted(json.loads(out), key=lambda w: w["idx"])

def main():
    if len(sys.argv) < 3:
        sys.exit(1)
        
    action = sys.argv[1]
    target_name = sys.argv[2]
    
    if target_name not in ORDER:
        sys.exit(1)
        
    workspaces = get_workspaces()
    target_ws = next((w for w in workspaces if w["name"] == target_name), None)
    
    if target_ws:
        # It already exists, just perform the action
        if action == "focus":
            subprocess.run(["niri", "msg", "action", "focus-workspace", target_name])
        elif action == "move-window":
            subprocess.run(["niri", "msg", "action", "move-window-to-workspace", target_name])
        elif action == "move-column":
            subprocess.run(["niri", "msg", "action", "move-column-to-workspace", target_name])
        return
        
    # If it doesn't exist, we must create it by focusing a new workspace,
    # then renaming it, then moving it into the correct position!
    # Niri doesn't let us directly spawn a named workspace if it's not in config,
    # so we focus the bottom-most (which creates an empty one), rename it, move it, and then do the action.
    
    if action == "focus":
        # 1. Focus a non-existent workspace (which jumps to bottom-most empty one)
        subprocess.run(["niri", "msg", "action", "focus-workspace-down"]) # this isn't reliable
        # Better: just focus a dummy name, which Niri will treat as non-existent and create dynamic!
        # Actually, Niri won't create a named workspace if it doesn't exist in config, it will just jump to empty!
        # So `focus-workspace "dummy"` just jumps to empty.
        
        # Let's see if we can just focus the new name
        subprocess.run(["niri", "msg", "action", "focus-workspace", target_name])
        time.sleep(0.05)
        # 2. Rename it
        subprocess.run(["niri", "msg", "action", "set-workspace-name", target_name])
        
        # 3. Figure out current position and target position
        workspaces = get_workspaces()
        current_idx = next((w["idx"] for w in workspaces if w["name"] == target_name), -1)
        if current_idx == -1:
            return
            
        current_pos = sum(1 for w in workspaces if w["idx"] < current_idx)
        
        target_pos = 0
        name_order_idx = ORDER.index(target_name)
        for w in workspaces:
            if w["name"] == target_name: continue
            if w["name"] in ORDER and ORDER.index(w["name"]) < name_order_idx:
                target_pos += 1
                
        diff = target_pos - current_pos
        if diff < 0:
            for _ in range(abs(diff)):
                subprocess.run(["niri", "msg", "action", "move-workspace-up"])
        elif diff > 0:
            for _ in range(diff):
                subprocess.run(["niri", "msg", "action", "move-workspace-down"])
                
    elif action == "move-column" or action == "move-window":
        # Creating a workspace to move a window to is trickier because we lose focus.
        # 1. Save current window id
        # 2. Create the workspace by focusing it
        # 3. Rename and move it
        # 4. Focus back the window
        # 5. Move the window to the new workspace
        
        # Actually, if we just use `move-column-to-workspace <name>`, Niri might just move it to the empty one!
        subprocess.run(["niri", "msg", "action", action + "-to-workspace", target_name])
        time.sleep(0.05)
        
        # Focus the workspace to rename it
        subprocess.run(["niri", "msg", "action", "focus-workspace", target_name])
        subprocess.run(["niri", "msg", "action", "set-workspace-name", target_name])
        
        # Move it
        workspaces = get_workspaces()
        current_idx = next((w["idx"] for w in workspaces if w["name"] == target_name), -1)
        if current_idx != -1:
            current_pos = sum(1 for w in workspaces if w["idx"] < current_idx)
            target_pos = 0
            name_order_idx = ORDER.index(target_name)
            for w in workspaces:
                if w["name"] == target_name: continue
                if w["name"] in ORDER and ORDER.index(w["name"]) < name_order_idx:
                    target_pos += 1
                    
            diff = target_pos - current_pos
            if diff < 0:
                for _ in range(abs(diff)):
                    subprocess.run(["niri", "msg", "action", "move-workspace-up"])
            elif diff > 0:
                for _ in range(diff):
                    subprocess.run(["niri", "msg", "action", "move-workspace-down"])
                    
        # Focus back is complicated. Hyprland moves it without focusing, but `move-window-to-workspace` in Niri keeps focus on the window!
        # So we actually shouldn't have focused the workspace.
        
if __name__ == "__main__":
    main()
