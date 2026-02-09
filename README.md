# practica3chaparro
script para configurar la máquina de bind


# 🌐 Laboratorio DNS con BIND – Dominio uno.net

Este repositorio contiene la configuración completa de un laboratorio
DNS usando **BIND9**, con tres servidores y resolución de nombres
accesible desde toda la red local (PCs y celulares).

---

## 📡 Topología de Red

Todos los equipos usan **Adaptador Puente** y están en la misma red LAN.

| Equipo | Hostname | IP |
|------|---------|----|
| DNS | bind.uno.net | 192.168.1.10 |
| S1 | www.uno.net | 192.168.1.20 |
| S2 | db1.uno.net | 192.168.1.21 |
| S3 | db2.uno.net | 192.168.1.22 |
| Router | Gateway | 192.168.1.1 |

---

## 🌍 Dominio Configurado

