# Delete vagrant snapshots from all mashines in Vagrantfile in current folder.

machines=$(vagrant status | grep 'virtualbox' | awk '{print $1}')
for machine in $machines; do
    echo "Machine: $machine"
    snapshots=$(vagrant snapshot list $machine | tail -n +2)
    echo "Snapshots: $snapshots"
    echo "Deleting snapshot for $machine"
    for snapshot in $snapshots; do
        echo "Deleting snapshot $snapshot for $machine"
        vagrant snapshot delete $machine $snapshot
    done
done
