FROM archlinux:latest

# Initialize keyring and install base packages
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo git base-devel libnewt

# Create a non-root user 'tester' and add to wheel group
RUN useradd -m -G wheel -s /bin/bash tester && \
    echo "tester ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER tester
WORKDIR /home/tester/sys-setup

# By default, start an interactive shell
CMD ["/bin/bash"]
