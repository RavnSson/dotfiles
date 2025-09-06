# Dotfile CodexSyn ⚝

Configuración personalizada de mi terminal en Linux (Bash).

Incluye:

- Intro:  
  - `Present day...` → `Present time...` (typewriter magenta)  
  - Banner ASCII **CodexSyn⚝** (verde CRT, con figlet)  
  - Fastfetch / Neofetch para mostrar info del sistema  
  - Frase de *Serial Experiments Lain* (typewriter magenta) cambia según el dia de la semana
- Prompt reactivo:  
  - Verde ✅ si el último comando fue exitoso  
  - Rojo ❌ si falló  
- Separador antes del prompt (sincronizado con el estado del comando)

---

## Restaurar en un sistema nuevo

1. Clonar el repo:
   ```bash
   git clone git@github.com:RavnSson/dotfiles.git ~/dotfiles
   ```

2. Copiar el `.bashrc` al home:
   ```bash
   cp ~/dotfiles/.bashrc ~/.bashrc
   ```

3. Recargar la configuración:
   ```bash
   source ~/.bashrc
   ```

---

## Dependencias recomendadas

Para aprovechar todas las funciones estéticas:

- **figlet** → para el banner ASCII  
- **lolcat** (opcional) → colores arcoíris en el banner  
- **fastfetch** o **neofetch** → mostrar información del sistema  

Instalar en Debian/Ubuntu:
```bash
sudo apt install figlet lolcat fastfetch -y
```

En Arch/Manjaro:
```bash
sudo pacman -S figlet lolcat fastfetch --noconfirm
```

---

## ✨ Notas

- Las frases de *Serial Experiments Lain* se encuentran en un array dentro del `.bashrc`.  
- Para añadir o cambiar frases, edita la sección `lain_quotes`.  
- Si **Fastfetch** o **Neofetch** no están instalados, la intro simplemente omite esa parte.  
- El prompt y el separador cambian de color dinámicamente según el éxito o error del último comando.  
