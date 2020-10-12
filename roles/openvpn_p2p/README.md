# Use

* Для использования роли достаточно поместить необходимые хосты в группу routers.

``` yaml
all:
  hosts:
  children:
    test_stand:
      children:
        routers:
          hosts:
            router1.soft-machine.tech:
              ansible_python_interpreter: /usr/bin/python3
            router2.soft-machine.tech:
              ansible_python_interpreter: /usr/bin/python3
            router3.soft-machine.tech:
              ansible_python_interpreter: /usr/bin/python3
            router4.soft-machine.tech:
              ansible_python_interpreter: /usr/bin/python3
```

* Сертификаты и все необходимые параметры генеряться автоматически.

``` yaml
- name: Generate random port
  set_fact:
    openvpn_p2p_port: "{{ 32767 |random(start=10000) }}"

- name: Generate random network octet
  set_fact:
      first_octet: "{{ 255 |random(start=170) }}"
      second_octet: "{{ 255 |random(start=170) }}"
```
