#!/bin/bash

pids_array[0]="$1"

index=0
pquit=0

while [ ${pquit} -eq 0 ]; do
    let index++

    # get all child processes to array
    get_pid=$(ps -o pid --ppid ${pids_array[$index-1]} | pcregrep '\d+' | tr \\n ' ')
    if [[ ! -z ${get_pid} ]]; then
        pids_array[$index]=${get_pid}
    else
        # if no child processes found to quit
        let pquit++
    fi
done

# kill process from parent to all child processes
pid_number="${#pids_array[@]}"
echo "${pid_number}"
for pid in $(seq 0 ${pid_number}); do
    if [ "${pids_array[$pid]}" ]; then
            echo "[$pid] kill => ${pids_array[$pid]}"
            kill ${pids_array[$pid]} &> /dev/null
        fi
    fi
done

exit 100